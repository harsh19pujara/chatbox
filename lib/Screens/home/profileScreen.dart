import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/Functionality/authentication.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.userData}) : super(key: key);
  final UserModel userData;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Authentication auth = Authentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.greenAccent,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 45,
                )),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Name',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.userData.name.toString(),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Email',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.userData.email.toString(),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              ' User Id',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.userData.id.toString(),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () async {
                  await auth.logOut().then((value) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      )));
                },
                child: const Text("Log Out"))
          ],
        ),
      ),
    );
  }
}
