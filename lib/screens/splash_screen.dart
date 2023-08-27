import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat_app/api/api.dart';
import 'package:we_chat_app/screens/auth/login_screen.dart';
import 'package:we_chat_app/screens/home_screen.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (APIs.auth.currentUser != null) {
        // log("\nUser: ${APIs.auth.currentUser}");
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: const Duration(seconds: 1),
              top: mq.height * .17,
              width: mq.width * .4,
              right: mq.width * .3,
              child: Image.asset('assets/images/app_icon.png')),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Column(
              children: [
                Text("Created by",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center),
                Text("Vrund",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)
              ],
            ),
          )
        ],
      ),
    );
  }
}
