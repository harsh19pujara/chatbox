import 'package:chatting_app/Functionality/authentication.dart';
import 'package:chatting_app/Screens/home/home.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/widgets/widgets.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Authentication _auth = Authentication();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String email = '';
    String pass = '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            IconButton(onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
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
                  padding: EdgeInsets.symmetric(horizontal: 70),
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
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color(0xFF24786D))),
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
                  onChanged: (value) {
                    pass = value;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFF24786D))),
                  obscureText: true,
                ),
                const SizedBox(
                  height: 100,
                ),
                GestureDetector(onTap: (){
                  if(formKey.currentState!.validate()){
                    setState(() {
                      isLoading = true;
                    });
                    print("setting state" + isLoading.toString());
                    _auth.login(email: email.trim(), pass: pass.trim()).then((value){
                      print('************  name  ${value!.name}  id ${value.email}  ${value.id}');
                      isLoading = false;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  HomeScreen(userData: value,)));
                    });

                  }
                  else{
                    const snackBar = SnackBar(
                      content: Text('Please Recheck the details'),
                      duration: Duration(seconds: 3),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },child: customButton(color: const Color(0xFF24786D),text: 'Log in', txtColor: Colors.white)),
                const SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Forgot Password ?',
                      style: TextStyle(
                          color: Color(0xFF24786D), fontWeight: FontWeight.w400,fontSize: 18)),
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
