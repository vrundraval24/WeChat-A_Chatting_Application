import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat_app/api/api.dart';
import 'package:we_chat_app/helper/dialogs.dart';
import 'package:we_chat_app/screens/home_screen.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {



  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);



  _handleLoginButtonClick() {
    // To show progress bar when clicked on log in button
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      // To hide progress bar when google login dialog box appear
      Navigator.pop(context);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Check for internet
      await InternetAddress.lookup('google.com');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      // ignore: use_build_context_synchronously
      Dialogs.showSnackbar(context,
          "Something went wrong. Please check your internet connection.", Colors.red);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent, // Set this to your desired color
    //   statusBarIconBrightness: Brightness.dark, // Set the brightness of the status bar icons
    // ));

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              top: mq.height * .15,
              width: mq.width * .4,
              right: mq.width * .3,
              child: Image.asset('assets/images/app_icon.png')),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width * .8,
              left: mq.width * .1,
              height: 50,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const StadiumBorder()),
                  onPressed: () {
                    _handleLoginButtonClick();
                  },
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 35,
                  ),
                  label: const Center(
                      child: Text(
                    "Log in with Google",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.normal),
                  ))))
        ],
      ),
    );
  }
}
