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
  final GlobalKey<FormState> _singUpFormKey = GlobalKey<FormState>();
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:CustomColor.authenticationBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leading: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
      ),
      body: isLoading == false
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                    key: _singUpFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                         Text(
                          'Sign up with Email',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                         Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Get chatting with friends and family today by signing up for our chat app!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
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
                               InputDecoration(labelText: 'Your Name', labelStyle: Theme.of(context).inputDecorationTheme.labelStyle),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
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
                               InputDecoration(labelText: 'Your Email', labelStyle:Theme.of(context).inputDecorationTheme.labelStyle),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
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
                              });}, icon: Icon(!showPass ? Icons.visibility_off : Icons.visibility)),labelText: 'Password', labelStyle: Theme.of(context).inputDecorationTheme.labelStyle),
                          obscureText: showPass,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
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
                              labelText: 'Confirm Password', labelStyle: Theme.of(context).inputDecorationTheme.labelStyle),
                          obscureText: showConfirmPass,
                        ),
                        SizedBox(
                          height: height / 11,
                        ),
                        GestureDetector(
                            onTap: () async {
                              print("Value $isLoading");
                              if (_singUpFormKey.currentState!.validate()) {
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
              children:  [
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  "Creating Account...",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400),
                )
              ],
            )),
    );
  }
}
