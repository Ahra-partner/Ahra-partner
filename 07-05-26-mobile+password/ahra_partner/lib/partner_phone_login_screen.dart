import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_router.dart';

class PartnerPhoneLoginScreen extends StatefulWidget {
  const PartnerPhoneLoginScreen({super.key});

  @override
  State<PartnerPhoneLoginScreen> createState() =>
      _PartnerPhoneLoginScreenState();
}

class _PartnerPhoneLoginScreenState
    extends State<PartnerPhoneLoginScreen> {

  final emailController =
      TextEditingController();

  final mobileController =
      TextEditingController();

  final loginController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool isLogin = true;

  bool obscurePassword = true;

  bool obscureConfirmPassword = true;

  // 🔥 CHECK MOBILE
  bool isMobile(String value) {

    return RegExp(r'^[0-9]{10}$')
        .hasMatch(value);
  }

  // 🔥 SIGNUP
  Future<void> signup() async {

    if (emailController.text
            .trim()
            .isEmpty ||
        mobileController.text
            .trim()
            .isEmpty ||
        passwordController.text
            .trim()
            .isEmpty ||
        confirmPasswordController
            .text
            .trim()
            .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Please fill all fields",
          ),
        ),
      );

      return;
    }

    // 🔥 MOBILE VALIDATION
    if (!isMobile(
      mobileController.text.trim(),
    )) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Enter valid mobile number",
          ),
        ),
      );

      return;
    }

    // 🔥 PASSWORD MATCH
    if (passwordController.text
            .trim() !=
        confirmPasswordController
            .text
            .trim()) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Passwords do not match",
          ),
        ),
      );

      return;
    }

    try {

      // 🔥 CREATE FIREBASE ACCOUNT
      final credential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(

        email:
            emailController.text
                .trim(),

        password:
            passwordController.text
                .trim(),
      );

      // 🔥 SAVE USER DATA
      await FirebaseFirestore.instance
          .collection("partners")
          .doc(credential.user!.uid)
          .set({

        "email":
            emailController.text
                .trim(),

        "mobile":
            mobileController.text
                .trim(),

        "createdAt":
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.of(context)
          .pushAndRemoveUntil(

        MaterialPageRoute(
          builder: (_) =>
              const AuthRouter(),
        ),

        (route) => false,
      );

    } on FirebaseAuthException catch (e) {

      String message =
          "Signup Failed";

      if (e.code ==
          'email-already-in-use') {

        message =
            "Email already exists";

      } else if (e.code ==
          'invalid-email') {

        message = "Invalid email";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // 🔥 LOGIN
  Future<void> login() async {

    if (loginController.text
            .trim()
            .isEmpty ||
        passwordController.text
            .trim()
            .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Please fill all fields",
          ),
        ),
      );

      return;
    }

    try {

      String email = "";

      final input =
          loginController.text
              .trim();

      print(input);

      // 🔥 LOGIN USING MOBILE
      if (isMobile(input)) {

        final query =
            await FirebaseFirestore
                .instance
                .collection("partners")
                .where(
                  "mobile",
                  isEqualTo: input,
                )
                .limit(1)
                .get();

        print(query.docs.length);

        if (query.docs.isEmpty) {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content: Text(
                "Mobile number not registered",
              ),
            ),
          );

          return;
        }

        email =
            query.docs.first["email"];

      } else {

        // 🔥 LOGIN USING EMAIL
        email = input;
      }

      // 🔥 FIREBASE LOGIN
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(

        email: email,

        password:
            passwordController.text
                .trim(),
      );

      if (!mounted) return;

      Navigator.of(context)
          .pushAndRemoveUntil(

        MaterialPageRoute(
          builder: (_) =>
              const AuthRouter(),
        ),

        (route) => false,
      );

    } on FirebaseAuthException catch (e) {

      String message =
          "Login Failed";

      if (e.code ==
          'user-not-found') {

        message = "User not found";

      } else if (e.code ==
          'wrong-password') {

        message = "Wrong password";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  // 🔥 FORGOT PASSWORD
  Future<void> forgotPassword() async {

    if (loginController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Enter email/mobile first",
          ),
        ),
      );

      return;
    }

    try {

      String email = "";

      final input =
          loginController.text
              .trim();

      // 🔥 IF MOBILE
      if (isMobile(input)) {

        final query =
            await FirebaseFirestore
                .instance
                .collection("partners")
                .where(
                  "mobile",
                  isEqualTo: input,
                )
                .limit(1)
                .get();

        if (query.docs.isEmpty) {

          ScaffoldMessenger.of(context)
              .showSnackBar(

            const SnackBar(
              content: Text(
                "Mobile number not found",
              ),
            ),
          );

          return;
        }

        email =
            query.docs.first["email"];

      } else {

        email = input;
      }

      // 🔥 SEND RESET MAIL
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Password reset email sent",
          ),
        ),
      );

    } on FirebaseAuthException catch (e) {

      String message =
          "Reset failed";

      if (e.code ==
          'user-not-found') {

        message = "User not found";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {

    emailController.dispose();

    mobileController.dispose();

    loginController.dispose();

    passwordController.dispose();

    confirmPasswordController
        .dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          isLogin
              ? "Partner Login"
              : "Partner Signup",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,

          children: [

            const SizedBox(height: 30),

            // 🔥 LOGIN FIELD
            if (isLogin)
              TextField(

                controller:
                    loginController,

                decoration:
                    const InputDecoration(

                  labelText:
                      "Email or Mobile Number",

                  border:
                      OutlineInputBorder(),
                ),
              ),

            // 🔥 SIGNUP EMAIL
            if (!isLogin)
              TextField(

                controller:
                    emailController,

                keyboardType:
                    TextInputType
                        .emailAddress,

                decoration:
                    const InputDecoration(

                  labelText: "Email",

                  border:
                      OutlineInputBorder(),
                ),
              ),

            // 🔥 SIGNUP MOBILE
            if (!isLogin) ...[

              const SizedBox(height: 20),

              TextField(

                controller:
                    mobileController,

                keyboardType:
                    TextInputType.phone,

                decoration:
                    const InputDecoration(

                  labelText:
                      "Mobile Number",

                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 🔥 PASSWORD
            TextField(

              controller:
                  passwordController,

              obscureText:
                  obscurePassword,

              decoration:
                  InputDecoration(

                labelText:
                    "Password",

                border:
                    const OutlineInputBorder(),

                suffixIcon:
                    IconButton(

                  onPressed: () {

                    setState(() {

                      obscurePassword =
                          !obscurePassword;
                    });
                  },

                  icon: Icon(

                    obscurePassword
                        ? Icons.visibility
                        : Icons
                            .visibility_off,
                  ),
                ),
              ),
            ),

            // 🔥 CONFIRM PASSWORD
            if (!isLogin) ...[

              const SizedBox(height: 20),

              TextField(

                controller:
                    confirmPasswordController,

                obscureText:
                    obscureConfirmPassword,

                decoration:
                    InputDecoration(

                  labelText:
                      "Confirm Password",

                  border:
                      const OutlineInputBorder(),

                  suffixIcon:
                      IconButton(

                    onPressed: () {

                      setState(() {

                        obscureConfirmPassword =
                            !obscureConfirmPassword;
                      });
                    },

                    icon: Icon(

                      obscureConfirmPassword
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 🔥 BUTTON
            ElevatedButton(

              onPressed:
                  isLogin
                      ? login
                      : signup,

              child: Text(

                isLogin
                    ? "Login"
                    : "Signup",
              ),
            ),

            // 🔥 FORGOT PASSWORD
            if (isLogin)
              TextButton(

                onPressed:
                    forgotPassword,

                child: const Text(
                  "Forgot Password?",
                ),
              ),

            // 🔥 SWITCH
            TextButton(

              onPressed: () {

                setState(() {

                  isLogin = !isLogin;
                });
              },

              child: Text(

                isLogin
                    ? "Don't have an account? Signup"
                    : "Already have an account? Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}