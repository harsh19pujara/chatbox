import 'package:chatting_app/Screens/authentication/signUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/widgets/widgets.dart';
import 'package:chatting_app/Screens/authentication/loginScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: SizedBox(
              height: height / 20,
              child: Image.asset('assets/images/loginAppBarLogo.png')),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SizedBox(
                height: height,
                width: width,
                child: Image.asset(
                  'assets/images/loginBackground.png',
                  fit: BoxFit.fill,
                )),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: width / 8, horizontal: height / 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height / 10,
                    ),
                    Text(
                      'Connect',
                      style: TextStyle(
                          fontSize: height/14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    Text('friends',
                        style: TextStyle(
                            fontSize: height/14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                    Text('easily &',
                        style: TextStyle(
                            fontSize: height/14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    Text('quickly',
                        style: TextStyle(
                            fontSize: height/14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                    SizedBox(
                      height: height/28,
                    ),
                    Text(
                      'Our chat app is the perfect way to stay connected with friends and family.',
                      style: TextStyle(
                          fontSize: height/45,
                          fontWeight: FontWeight.w300,
                          color: Colors.white),
                    ),
                    SizedBox(height: height/28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        circularLogo('assets/images/instagramLogo.png'),
                        SizedBox(width: height/28),
                        circularLogo('assets/images/googleLogo.png'),
                        SizedBox(width: height/28),
                        circularLogo('assets/images/appleLogo.png')
                      ],
                    ),
                    SizedBox(height: height/20),
                    Center(child: Image.asset('assets/images/orLogoLogin.png')),
                    SizedBox(height: height/20),
                    Center(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUpScreen()));
                            },
                            child: customButton(color: Colors.white,text: 'Sign up with Email', txtColor: Colors.black))),
                    SizedBox(
                      height: height/38,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Existing Account ?  ',
                          style: TextStyle(color: Colors.white,fontSize: height/46),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, color: Colors.white,fontSize: height/44),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
