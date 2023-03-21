import 'dart:async';

import 'package:chatting_app/Functionality/authentication.dart';
import 'package:chatting_app/Helper/themes.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/home.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:chatting_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final Authentication _auth = Authentication();
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late UserModel temp;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool showPass = false;
  bool showConfirmPass = false;


  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController pass = TextEditingController();

  String checkPass = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:CustomColor.authenticationBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: isLoading == false
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          'Sign up with Email',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32,),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Get chatting with friends and family today by signing up for our chat app!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          height: 60,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.name,
                          controller: name,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Your Name';
                            } else {
                              return null;
                            }
                          },
                          decoration:
                              const InputDecoration(labelText: 'Your Name', labelStyle: TextStyle(color: CustomColor.authenticationLabel)),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: email,
                          validator: (value) {
                            if (!value!.contains('@')) {
                              return 'Please enter proper email address';
                            } else {
                              return null;
                            }
                          },
                          decoration:
                              const InputDecoration(labelText: 'Your Email', labelStyle: TextStyle(color:CustomColor.authenticationLabel)),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          validator: (value) {
                            if (value!.length < 8) {
                              return 'Please enter 8 digit password';
                            } else {
                              checkPass = value;
                              return null;
                            }
                          },
                          controller: pass,
                          decoration:
                              InputDecoration(suffixIcon: IconButton(onPressed: (){setState(() {
                                showPass = !showPass;
                              });}, icon: Icon(!showPass ? Icons.visibility_off : Icons.visibility)),labelText: 'Password', labelStyle: const TextStyle(color: CustomColor.authenticationLabel)),
                          obscureText: showPass,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          validator: (value) {
                            if (value != checkPass) {
                              return 'Password does not match !! Please Re-enter';
                            } else {
                              return null;
                            }
                          },
                          decoration:  InputDecoration(suffixIcon: IconButton(onPressed: (){setState(() {
                            showConfirmPass = !showConfirmPass;
                          });}, icon: Icon(!showConfirmPass ? Icons.visibility_off : Icons.visibility,)),
                              labelText: 'Confirm Password', labelStyle: const TextStyle(color: CustomColor.authenticationLabel)),
                          obscureText: showConfirmPass,
                        ),
                        SizedBox(
                          height: height / 8,
                        ),
                        GestureDetector(
                            onTap: () async {
                              print("Value $isLoading");
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                _auth.signUp(name: name.text, email: email.text.trim(), pass: pass.text.trim()).then((value) {
                                  if (value != null) {
                                    print("After Value $isLoading");

                                    isLoading = false;

                                    FirebaseFirestore.instance.collection("users").doc(auth.currentUser!.uid).update({"isOnline": true});

                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                          userData: value,
                                        )), (route) => false);
                                  }
                                });
                              } else {
                                // isLoading = false;
                                const snackBar = SnackBar(
                                  content: Text('Please Recheck the details'),
                                  duration: Duration(seconds: 3),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            },
                            child:
                                customButton(color: CustomColor.authenticationButtonColor, text: 'Create an Account', txtColor: CustomColor.authenticationButtonText))
                      ],
                    )),
              ),
            )
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Creating Account...",
                  style: TextStyle(fontSize: 22),
                )
              ],
            )),
    );
  }
}
