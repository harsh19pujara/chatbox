import 'package:chatting_app/Helper/themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/welcomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chatting_app/Functionality/authentication.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key, required this.userData}) : super(key: key);
  final UserModel userData;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Authentication auth = Authentication();
  File? profileImage;
  UserModel? userDataLatest;


  getImage(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);
    print("image ");

    if (pickedImage != null) {
      cropImage(pickedImage);
      print("image fetched");
    }
  }

  cropImage(XFile pic) async {
    CroppedFile? croppedImg = await ImageCropper().cropImage(
      sourcePath: pic.path,
    );

    if (croppedImg != null) {
      print("image cropped");
      setState(() {
        profileImage = File(croppedImg.path);
        uploadImage();
        Navigator.pop(context);
      });
    }
  }

  uploadImage() async {
    if (profileImage != null) {
      TaskSnapshot uploading =
          await FirebaseStorage.instance.ref("ProfilePics").child(widget.userData.id.toString()).putFile(profileImage!);

      String profileUrl = await uploading.ref.getDownloadURL();

      if (profileUrl.isNotEmpty) {
        widget.userData.profile = profileUrl;
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userData.id)
            .update(widget.userData.toMap())
            .then((value) async{
          print("done Uploading");
          await gettingUserData();
        });
      } else {
        print("error getting url");
      }
    } else {
      print("no profile pic found");
    }
  }

  Future<void> gettingUserData() async{
    DocumentSnapshot data =  await FirebaseFirestore.instance.collection("users").doc(widget.userData.id.toString()).get();
    Map<String,dynamic> temp = data.data() as Map<String,dynamic>;
    userDataLatest = UserModel.fromJson(temp);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    gettingUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.fromLTRB(25, 35, 25, 0),
        decoration: const BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                              title: const Center(child: Text("Upload a Profile Picture")),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 15,),
                                  Container(
                                    height: 250,
                                    color: Colors.black26,
                                    child: userDataLatest != null ? (userDataLatest!.profile != null && userDataLatest!.profile != ""
                                        ? FittedBox(fit: BoxFit.fill, child: Image.network(userDataLatest!.profile.toString()))
                                        : const Center(child: Icon(Icons.person,color: Colors.white,size: 50,))) : Container(),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  ListTile(
                                    onTap: () {
                                      getImage(ImageSource.gallery);
                                    },
                                    title: const Text("Upload from Gallery"),
                                    leading: const Icon(Icons.photo),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      getImage(ImageSource.camera);

                                    },
                                    title: const Text("Take a Picture"),
                                    leading: const Icon(Icons.camera_alt),
                                  ),
                                  ListTile(
                                    onTap: () async{
                                      await FirebaseStorage.instance.ref("ProfilePics").child(widget.userData.id.toString()).delete().then((value) async{
                                        Navigator.pop(context);
                                        await FirebaseFirestore.instance.collection("users").doc(widget.userData.id.toString()).update({"profile" : ""}).then((value) async{
                                          await gettingUserData();
                                        });
                                      });
                                    },
                                    title: const Text("Remove Picture"),
                                    leading: const Icon(Icons.remove_circle_sharp),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                          radius: 35,
                          backgroundImage: userDataLatest != null ? (userDataLatest!.profile != null && userDataLatest!.profile != ""
                              ? NetworkImage(userDataLatest!.profile.toString())
                              : null) : null,
                          backgroundColor: CustomColor.userColor,
                          child: userDataLatest != null ?(userDataLatest!.profile != null && userDataLatest!.profile != ""
                              ? Container() :
                              const Center(
                                child:  Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                              )) : Container()),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.userData.name.toString(),
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 24), overflow: TextOverflow.fade),
                          Text(widget.userData.email.toString(),
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16, fontWeight: FontWeight.w300))
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.qr_code_2,
                          size: 30,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
                optionTile(icon: Icons.key, name: "Account", details: "Privacy, security, change number"),
                optionTile(icon: Icons.chat_sharp, name: "Chat", details: "Chat history,theme,wallpapers"),
                optionTile(icon: Icons.notifications_none_sharp, name: "Notifications", details: "Messages, group and others"),
                optionTile(icon: Icons.help_outline_sharp, name: "Help", details: "Help center,contact us, privacy policy"),
                optionTile(icon: Icons.compare_arrows_sharp, name: "Storage and Data", details: "Network usage, storage usage"),
                optionTile(icon: Icons.person_add_alt_1_sharp, name: "Invite A Friend", details: ""),
                const SizedBox(
                  height: 25,
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.black26, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                    onPressed: () async {
                      await auth.logOut().then((value) {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(widget.userData.id.toString())
                            .update({"isOnline": false});

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WelcomeScreen(),
                            ),
                            (route) => false);
                      });
                    },
                    child: Text(
                      "Log Out",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                const SizedBox(height: 15,),
                Text(widget.userData.id.toString(),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget optionTile({required IconData icon, required String name, required String details}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFF2F8F7),
              child: Icon(
                icon,
                color: const Color(0xFF797C7B),
              )),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyLarge, overflow: TextOverflow.fade),
                Text(details, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
