import 'dart:io';

import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/Functionality/authentication.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.userData, this.searchedUser}) : super(key: key);
  final UserModel userData;
  final UserModel? searchedUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Authentication auth = Authentication();
  File? profileImage;

  getImage(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);
    print("image ");

    if(pickedImage != null){
      cropImage(pickedImage);
      print("image fetched");
    }
  }

  cropImage(XFile pic) async{
    CroppedFile? croppedImg = await ImageCropper().cropImage(sourcePath: pic.path,);

    if(croppedImg != null){
      print("image cropped");
      setState(() {
        profileImage = File(croppedImg.path);
      });
    }
  }

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
            GestureDetector(
              onTap: (){
                showDialog(context: context, builder: (context) {
                  return AlertDialog(title: const Text("Upload a Profile Picture"),content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(onTap: (){
                        getImage(ImageSource.gallery);
                      },title: const Text("Upload from Gallery"),leading: const Icon(Icons.photo),),
                      ListTile(onTap: (){
                        getImage(ImageSource.camera);
                      },title: const Text("Take a Picture"),leading: const Icon(Icons.camera_alt),)

                    ],
                  ),);
                },);
              },
              child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
                  backgroundColor: Colors.greenAccent,
                  child: profileImage != null ? null : const Icon(
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
              widget.searchedUser == null ? widget.userData.name.toString() : widget.searchedUser!.name.toString(),
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
              widget.searchedUser == null ? widget.userData.email.toString() : widget.searchedUser!.email.toString(),
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
              widget.searchedUser == null ? widget.userData.id.toString() : widget.searchedUser!.id.toString(),
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(
              height: 50,
            ),
            widget.searchedUser == null
                ? ElevatedButton(
                    onPressed: () async {
                      await auth.logOut().then((value) {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.userData.id.toString())
                            .update({"isOnline": false});

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ));
                        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        // builder: (context) => const WelcomeScreen(), (route) => false)
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                            (route) => false);
                      });
                    },
                    child: const Text("Log Out"))
                : Container()
          ],
        ),
      ),
    );
  }
}
