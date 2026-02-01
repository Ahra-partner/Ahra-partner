import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  // ================= SELFIE (FRONT CAMERA) =================
  static Future<File?> pickSelfieCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 100, // we compress manually
    );

    if (picked == null) return null;
    return _compress(File(picked.path));
  }

  // ================= DOCUMENT FROM CAMERA =================
  static Future<File?> pickDocumentFromCamera() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (picked == null) return null;
    return _compress(File(picked.path));
  }

  // ================= DOCUMENT FROM GALLERY =================
  static Future<File?> pickDocumentFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (picked == null) return null;
    return _compress(File(picked.path));
  }

  // ================= IMAGE COMPRESSION =================
  static Future<File> _compress(File file) async {
    final bytes = await file.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);

    if (decoded == null) return file;

    // Resize (keeps quality, reduces size)
    final resized = img.copyResize(decoded, width: 900);

    // Temporary directory
    final dir = await getTemporaryDirectory();
    final target = File(
      '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    // Compress to ~200–300 KB
    final Uint8List jpg = Uint8List.fromList(
      img.encodeJpg(resized, quality: 60),
    );

    await target.writeAsBytes(jpg);
    return target;
  }
}
