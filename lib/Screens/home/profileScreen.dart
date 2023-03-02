import 'dart:io';

import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/Functionality/authentication.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.searchedUser}) : super(key: key);
  final UserModel searchedUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Authentication auth = Authentication();
  File? profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            GestureDetector(
              onTap: () {},
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                  backgroundColor: Colors.greenAccent,
                  child: profileImage != null
                      ? null
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 45,
                        )),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Name',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.searchedUser.name.toString(),
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
              widget.searchedUser.email.toString(),
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
              widget.searchedUser.id.toString(),
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}
