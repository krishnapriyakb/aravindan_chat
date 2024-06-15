import 'dart:io';

import 'package:chat/api_services/api_services.dart';
import 'package:chat/screens/home_page.dart';
import 'package:chat/utils/dialogues.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  fnHandleGoogleBtnClick() {
    CustomSnackBar.showProgressBar(context);
    signInWithGoogle().then((value) async {
      Navigator.pop(context);
      if (value != null) {
        if (await ApiServices.userExist()) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (value) => const HomePage(),
            ),
          );
        } else {
          await ApiServices.createUser().then((value) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (value) => const HomePage(),
              ),
            );
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await ApiServices.auth.signInWithCredential(credential);
    } catch (e) {
      if (kDebugMode) {
        print("signInWithGoogle : $e");
      }
      CustomSnackBar.showSnackBar(
          context, "Something went wrong check your internet connection");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/images/chat.png",
              height: 100,
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          ElevatedButton.icon(
            onPressed: () {
              fnHandleGoogleBtnClick();
            },
            icon: const Icon(
              Icons.bus_alert,
            ),
            label: const Text(
              'Login with Google',
            ),
          ),
        ],
      ),
    );
  }
}
