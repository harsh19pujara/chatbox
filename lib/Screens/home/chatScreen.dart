import 'dart:io';

import 'package:chatting_app/Model/chatModel.dart';
import 'package:chatting_app/Model/messageModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/profileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.chatRoom, required this.currentUser, required this.searchedUser}) : super(key: key);
  final ChatModel chatRoom;
  final UserModel currentUser;
  final UserModel searchedUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final uuid = const Uuid();
  MessageModel? msgDetails;
  TextEditingController msgController = TextEditingController();
  File? chatImage;

  @override
  void initState() {
    updateUserOnlineStatus(true);
    super.initState();
  }

  updateUserOnlineStatus(bool status) async {
    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(widget.chatRoom.chatRoomId)
        .update({"online.${widget.currentUser.id.toString()}": status});
  }

  updateMessageOnlineStatus(String docId, bool status) async {
    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(widget.chatRoom.chatRoomId)
        .collection("messages")
        .doc(docId)
        .update({"seen": status}).then((value) {});
  }

  openImagePicker() async {
    var file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      chatImage = File(file.path);
      uploadImage();
    }
  }

  uploadImage() async {
    var uploadedFile =
        await FirebaseStorage.instance.ref(widget.chatRoom.chatRoomId.toString()).child(uuid.v1()).putFile(chatImage!);

    String url = await uploadedFile.ref.getDownloadURL();

    if (url.isNotEmpty) {
      var data = MessageModel(
          msgType: "img", msg: url, msgId: uuid.v1(), senderId: widget.currentUser.id, createdOn: Timestamp.now(), seen: false);

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoom.chatRoomId.toString())
          .collection("messages")
          .doc(data.msgId)
          .set(data.toMap())
          .then((value) async {
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(widget.chatRoom.chatRoomId)
            .update({"lastMsgTime": data.createdOn, "lastMsg": "Photo"});
      });
    }
  }

  final snackBar = const SnackBar(content: Text("Error launching URL"));

  @override
  void dispose() {
    updateUserOnlineStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,
          leadingWidth: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.black,
                  )),
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFa8e5f0),
                backgroundImage: widget.searchedUser.profile != "" && widget.searchedUser.profile != null
                    ? NetworkImage(widget.searchedUser.profile.toString())
                    : null,
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(searchedUser: widget.searchedUser),
                          ));
                    },
                    icon: widget.searchedUser.profile != "" && widget.searchedUser.profile != null
                        ? Container()
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                          )),
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.searchedUser.name.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  Text(
                    widget.searchedUser.email.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),
                  )
                ],
              )
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.call,
                  color: Colors.black,
                )),
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Do you want to Delete All Chats and Photos ? "),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black, fontSize: 18),
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            TextButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(widget.chatRoom.chatRoomId.toString())
                                      .collection("messages")
                                      .get()
                                      .then((value) {
                                    for (var docs in value.docs) {
                                      docs.reference.delete();
                                    }
                                  }).then((value) async {
                                    await FirebaseStorage.instance.ref(widget.chatRoom.chatRoomId.toString()).listAll().then((value) {
                                      for (var element in value.items) {
                                        element.delete();
                                      }
                                    }).then((value) async{
                                      Navigator.pop(context);
                                      await FirebaseFirestore.instance
                                          .collection("chatRooms")
                                          .doc(widget.chatRoom.chatRoomId.toString())
                                          .update({"lastMsg": ""});
                                    });
                                  });
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red, fontSize: 18)))
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.black,
                ))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                // ************* CHECKING FRIEND ONLINE STATUS  ******************
                child: StreamBuilder(
                  stream:
                      FirebaseFirestore.instance.collection("chatRooms").doc(widget.chatRoom.chatRoomId.toString()).snapshots(),
                  builder: (context, chatRoomSnapshot) {
                    return StreamBuilder(
                      // ************* FETCHING CHAT DATA  ******************
                      stream: FirebaseFirestore.instance
                          .collection("chatRooms")
                          .doc(widget.chatRoom.chatRoomId.toString())
                          .collection("messages")
                          .orderBy("createdOn", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<MessageModel> messageList = snapshot.data!.docs.map((e) {
                            return MessageModel.fromJson(e.data());
                          }).toList();

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              reverse: true,
                              itemCount: messageList.length,
                              itemBuilder: (context, index) {
                                if (chatRoomSnapshot.hasData) {
                                  if (messageList[index].senderId.toString() != widget.currentUser.id.toString()) {
                                    print("condition ${messageList[index].msg} ${widget.currentUser.id.toString()} ");
                                    bool isOnline = chatRoomSnapshot.data!["online"][widget.currentUser.id];
                                    print(isOnline.toString());
                                    if (isOnline == true && messageList[index].seen == false) {
                                      print("try updating");
                                      updateMessageOnlineStatus(messageList[index].msgId.toString(), true);
                                    }
                                  }
                                }
                                //*************************   SHOW TEXT IN CHAT   *******************************
                                if (messageList[index].msgType == "text") {
                                  return SizedBox(
                                    // color: Colors.blueGrey,
                                    width: MediaQuery.of(context).size.width - 100,
                                    child: Row(
                                        mainAxisAlignment: messageList[index].senderId == widget.currentUser.id
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              messageList[index].senderId.toString() == widget.currentUser.id.toString()
                                                  ? Icon(Icons.check,
                                                      color: messageList[index].seen == true ? Colors.blue : Colors.grey,
                                                      size: 17)
                                                  : Container(),
                                              const SizedBox(width: 2),
                                              LimitedBox(
                                                maxWidth: 300,
                                                child: Container(
                                                    margin: const EdgeInsets.symmetric(vertical: 3),
                                                    padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                                                    decoration: BoxDecoration(
                                                        color: messageList[index].senderId == widget.currentUser.id
                                                            ? const Color(0xFFb3f2c7)
                                                            : const Color(0xFFa8e5f0),
                                                        borderRadius: messageList[index].senderId == widget.currentUser.id
                                                            ? const BorderRadius.only(
                                                                bottomRight: Radius.circular(15),
                                                                topRight: Radius.zero,
                                                                topLeft: Radius.circular(15),
                                                                bottomLeft: Radius.circular(15))
                                                            : const BorderRadius.only(
                                                                bottomRight: Radius.circular(15),
                                                                topRight: Radius.circular(15),
                                                                topLeft: Radius.zero,
                                                                bottomLeft: Radius.circular(15))),
                                                    child: Linkify(
                                                      onOpen: (link) async {
                                                        if (await canLaunchUrl(Uri.parse(link.url))) {
                                                          await launchUrl(
                                                            Uri.parse(link.url),
                                                            mode: LaunchMode.externalApplication,
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                        }
                                                      },
                                                      text: messageList[index].msg.toString(),
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w400,
                                                          color: messageList[index].senderId == widget.currentUser.id
                                                              ? Colors.black
                                                              : Colors.black),
                                                      softWrap: true,
                                                      maxLines: null,
                                                      linkifiers: const [EmailLinkifier(), UrlLinkifier()],
                                                      linkStyle: const TextStyle(color: Colors.blueAccent),
                                                      textAlign: TextAlign.start,
                                                    )),
                                              ),
                                              const SizedBox(width: 2),
                                              messageList[index].senderId.toString() != widget.currentUser.id.toString()
                                                  ? Icon(Icons.check,
                                                      color: messageList[index].seen == true ? Colors.blue : Colors.grey,
                                                      size: 17)
                                                  : Container()
                                            ],
                                          )
                                        ]),
                                  );
                                }
                                // ****************** SHOW IMAGES IN CHAT *********************
                                else if (messageList[index].msgType == "img") {
                                  return Row(
                                      mainAxisAlignment: messageList[index].senderId == widget.currentUser.id
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        messageList[index].senderId == widget.currentUser.id
                                            ? Icon(
                                                Icons.check,
                                                color: messageList[index].seen! ? Colors.blueAccent : Colors.grey,
                                              )
                                            : Container(),
                                        LimitedBox(
                                          maxWidth: MediaQuery.of(context).size.width / 2,
                                          maxHeight: MediaQuery.of(context).size.height / 3,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ShowImage(imgUrl: messageList[index].msg.toString()),
                                                  ));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(3),
                                              margin: EdgeInsets.symmetric(vertical: 3),
                                              child: Image.network(
                                                messageList[index].msg.toString(),
                                                fit: BoxFit.fitHeight,
                                              ),
                                            ),
                                          ),
                                        ),
                                        messageList[index].senderId != widget.currentUser.id
                                            ? Icon(
                                                Icons.check,
                                                color: messageList[index].seen! ? Colors.blueAccent : Colors.grey,
                                              )
                                            : Container(),
                                      ]);
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Text("Please Check Your Internet Connection");
                        } else {
                          return const Text("Say Hii to Your Friend");
                        }
                      },
                    );
                  },
                ),
              ),
              //****************   BOTTOM TEXT FIELD, SEND IMAGES   ************************
              Container(
                // height: 60,
                margin: const EdgeInsets.all(5),
                // color: Colors.red,
                // padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          openImagePicker();
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(2),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            minimumSize: const Size(40, 50)),
                        child: SizedBox(
                            child: Image.asset(
                          "assets/images/Clip.png",
                          width: 22,
                        ))),
                    Flexible(
                        child: LimitedBox(
                      maxHeight: 70,
                      child: TextField(
                        controller: msgController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.transparent)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            filled: true,
                            fillColor: Colors.black12,
                            hintText: "Enter Text...",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.transparent))),
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF20A090),
                        radius: 25,
                        child: IconButton(
                            onPressed: () {
                              if (msgController.text.isNotEmpty) {
                                msgDetails = MessageModel(
                                    msg: msgController.text,
                                    msgId: uuid.v1(),
                                    senderId: widget.currentUser.id,
                                    createdOn: Timestamp.now(),
                                    seen: false,
                                    msgType: "text");
                                if (msgDetails != null) {
                                  FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(widget.chatRoom.chatRoomId.toString())
                                      .collection("messages")
                                      .doc(msgDetails!.msgId.toString())
                                      .set(msgDetails!.toMap());

                                  // print("msg send  ++++++++++++++++++++++++++++++++++++:::::::::::::::::::::");
                                  // print(widget.chatRoom.lastMsg);
                                  FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(widget.chatRoom.chatRoomId.toString())
                                      .update({"lastMsg": msgController.text.toString(), "lastMsgTime": msgDetails!.createdOn});
                                  msgController.clear();
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.send_sharp,
                              color: Colors.white,
                            )),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class ShowImage extends StatelessWidget {
  final String imgUrl;

  const ShowImage({required this.imgUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(top: true,bottom: true,child: Container(height: double.maxFinite, width: double.maxFinite, color: Colors.black, child: Image.network(imgUrl))),
    );
  }
}
