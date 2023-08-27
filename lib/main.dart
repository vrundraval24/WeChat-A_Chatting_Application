import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:we_chat_app/screens/home_screen.dart';
import 'package:we_chat_app/screens/splash_screen.dart';
import 'firebase_options.dart';

late Size mq;

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firebase
  _initializeFirebase();

  // To open the splash screen in full screen
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Set the status bar color to match the AppBar color
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Set this to your desired color
    statusBarIconBrightness: Brightness.light, // Set the brightness of the status bar icons
  ));

  // Setting orientation to portrait only and to handle glitches we first completely set orientation and THEN run any other code
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {

    // WidgetsFlutterBinding.ensureInitialized();

    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // mq = MediaQuery.of(context).size;

    return MaterialApp(
      title: 'WeChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.normal),
            backgroundColor: Colors.black),

        //
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        // useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
