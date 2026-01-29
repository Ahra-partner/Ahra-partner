import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class KycStorageHelper {
  static Future<String> uploadKycImage({
    required File file,
    required String partnerId,
    required String docName, // selfie / aadhaar_front etc
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('kyc/$partnerId/$docName.jpg');

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
