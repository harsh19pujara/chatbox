import 'package:chatting_app/Screens/authentication/signUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/widgets/widgets.dart';
import 'package:chatting_app/Screens/authentication/loginScreen.dart';
import 'package:chatting_app/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(

          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: SizedBox(height: height / 20, child: Image.asset('assets/images/loginAppBarLogo.png')),
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
              padding: EdgeInsets.symmetric(vertical: width / 8, horizontal: height / 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height / 17,
                    ),
                    Text(
                      'Connect',
                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w500,color: Colors.white),
                    ),
                    Text('friends', style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w500)),
                    Text('easily &', style : Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w900)),
                    Text('quickly', style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.w900)),
                    SizedBox(
                      height: height / 28,
                    ),
                    Text(
                      'Our chat app is the perfect way to stay connected with friends and family.',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w300),
                    ),
                    SizedBox(height: height / 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        circularLogo('assets/images/instagramLogo.png'),
                        SizedBox(width: height / 28),
                        circularLogo('assets/images/googleLogo.png'),
                        SizedBox(width: height / 28),
                        circularLogo('assets/images/appleLogo.png')
                      ],
                    ),
                    SizedBox(height: height / 20),
                    Center(child: Image.asset('assets/images/orLogoLogin.png')),
                    SizedBox(height: height / 20),
                    Center(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                            },
                            child: customButton(color: Colors.white, text: 'Sign up with Email', txtColor: Colors.black))),
                    SizedBox(
                      height: height / 38,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Existing Account ?  ',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                          child: Text(
                            'Log In',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w500),
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
