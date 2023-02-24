import 'package:chatting_app/Functionality/authentication.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/home.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/widgets/widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    String checkPass = '';

    String email = '';
    String name = '';
    String pass = '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Container(
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
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
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
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Your Name';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: const InputDecoration(labelText: 'Your Name', labelStyle: TextStyle(color: Color(0xFF24786D))),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (!value!.contains('@')) {
                      return 'Please enter proper email address';
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: const InputDecoration(labelText: 'Your Email', labelStyle: TextStyle(color: Color(0xFF24786D))),
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
                  onChanged: (value) {
                    pass = value;
                  },
                  decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: Color(0xFF24786D))),
                  obscureText: true,
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
                  decoration:
                      const InputDecoration(labelText: 'Confirm Password', labelStyle: TextStyle(color: Color(0xFF24786D))),
                  obscureText: true,
                ),
                SizedBox(
                  height: height / 8,
                ),
                GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        _auth.signUp(name: name, email: email.trim(), pass: pass.trim()).then((value) {
                          temp = value!;
                          print('in $value');
                          if(value != null){
                            print("boiii  $value");

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                        userData: temp,
                                      )));
                          }
                        });
                      } else {
                        const snackBar = SnackBar(
                          content: Text('Please Recheck the details'),
                          duration: Duration(seconds: 3),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: customButton(color: const Color(0xFF24786D), text: 'Create an Account', txtColor: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
