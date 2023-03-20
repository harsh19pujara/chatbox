import 'dart:async';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/authentication/loginScreen.dart';
import 'package:chatting_app/Screens/home/home.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:chatting_app/Screens/splashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userLoginFlag = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  UserModel? userData;

  @override
  void initState() {
    Timer(
      Duration(seconds: 2),
      () {
        checkIfLogin();
      },
    );
    print('1');
    super.initState();
    print("3");

    // print("4");
  }

  checkIfLogin() async {
    auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        DocumentSnapshot data = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
        var temp = data.data() as Map<String, dynamic>;
        userData = UserModel.fromJson(temp);
        if (this.mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(userData: userData!)));
        }
        // setState(() {
        //   userLoginFlag = true;
        // });
      } else {
        if (this.mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
