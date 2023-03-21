import 'package:chatting_app/Functionality/authentication.dart';
import 'package:chatting_app/Helper/themes.dart';
import 'package:chatting_app/Screens/home/home.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/widgets/widgets.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Authentication _auth = Authentication();
  bool isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool showPass = false;
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: CustomColor.authenticationBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            IconButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
            }, icon: const Icon(Icons.arrow_back,color: Colors.black,)),
      ),
      body: Container(
        padding: const EdgeInsets.only(right: 20,left: 20,top: 80,bottom: 20),
        child: Form(
          key: formKey,
          child: isLoading == false ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30,),
                const Text(
                  'Log in to ChatBox',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                      'Welcome back! Sign in using your social account or email to continue us',textAlign: TextAlign.center,),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    circularLogo('assets/images/instagramLogo.png'),
                    const SizedBox(width: 30),
                    circularLogo('assets/images/googleLogo.png'),
                    const SizedBox(width: 30),
                    circularLogo('assets/images/appleLogo.png')
                  ],
                ),
                const SizedBox(height: 20),
                Center(child: Image.asset('assets/images/orLogoBlack.png')),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (!value!.contains('@')) {
                      return 'Please enter proper email address';
                    }
                    else{
                      return null;
                    }
                  },
                controller: email,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: CustomColor.authenticationLabel)),
                ),
                TextFormField(
                  validator: (value) {
                    if(value!.length <8){
                      return 'Please enter 8 digit password';
                    }
                    else{
                      return null;
                    }
                  },
                  controller: pass,
                  // focusNode: FocusNode(),

                  decoration:  InputDecoration(
                    suffixIcon: IconButton(onPressed: (){setState(() {
                      showPass = !showPass;
                    });}, icon: Icon(showPass ? Icons.visibility : Icons.visibility_off)),
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: CustomColor.authenticationLabel)),
                  obscureText: showPass,
                ),
                const SizedBox(
                  height: 100,
                ),
                GestureDetector(onTap: (){
                  if(formKey.currentState!.validate()){
                    setState(() {
                      isLoading = true;
                    });
                    _auth.login(email: email.text.toString().trim(), pass: pass.text.toString().trim()).then((value){
                      print('************  name  ${value!.name}  id ${value.email}  ${value.id}');
                      isLoading = false;
                      FirebaseFirestore.instance.collection("users").doc(auth.currentUser!.uid).update({"isOnline": true});
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) =>  HomeScreen(userData: value,)), (route) => false);
                    });

                  }
                  else{
                    const snackBar = SnackBar(
                      content: Text('Please Recheck the details'),
                      duration: Duration(seconds: 2),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },child: customButton(color: CustomColor.authenticationButtonColor,text: 'Log in', txtColor: CustomColor.authenticationButtonText)),
                const SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Forgot Password ?',
                      style: TextStyle(
                          color: CustomColor.authenticationButtonColor, fontWeight: FontWeight.w400,fontSize: 18)),
                )
              ],
            ),
          ) :  Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 30,),
              Text("Fetching Data...", style: TextStyle(fontSize: 22),)
            ],
          )),
        ),
      ),
    );
  }
}
