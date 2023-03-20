import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/Model/chatGroupModel.dart';
import 'package:chatting_app/Model/messageModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/profileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({Key? key, required this.chatGroup, required this.currentUser}) : super(key: key);
  final ChatGroupModel chatGroup;
  final UserModel currentUser;

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  TextEditingController msgController = TextEditingController();
  final uuid = const Uuid();
  MessageModel? msgDetails;
  List<MessageModel> allMsg = [];
  List<UserModel> participantData = [];
  Map<String, String> participantsName = {};
  MessageModel? prevMsg;
  MessageModel? currentMsg;
  bool showUserName = false;
  File? chatImage;

  @override
  void initState() {
    fetchFriendsDetails().then((value) {
      setState(() {});
    });
    updateUnreadMsg();
    super.initState();
  }

  openImagePicker() async {
    var file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      chatImage = File(file.path);

      var data = MessageModel(
          msgType: "img",
          msg: "dummy data",
          msgId: uuid.v1(),
          senderId: widget.currentUser.id,
          createdOn: Timestamp.now(),
          seen: false);
      
      await FirebaseFirestore.instance
          .collection("chatGroups")
          .doc(widget.chatGroup.chatRoomId.toString())
          .collection("messages")
          .doc(data.msgId)
          .set(data.toMap()).then((value) {
        uploadImage(data: data);
      });


  }
  }

  uploadImage({required MessageModel data}) async {
    var uploadedFile =
    await FirebaseStorage.instance.ref(widget.chatGroup.chatRoomId.toString()).child(uuid.v1()).putFile(chatImage!);

    String url = await uploadedFile.ref.getDownloadURL();

    if (url.isNotEmpty) {

      await FirebaseFirestore.instance
          .collection("chatGroups")
          .doc(widget.chatGroup.chatRoomId.toString())
          .collection("messages")
          .doc(data.msgId)
          .update({'msg' : url.toString()})
          .then((value) async {
        await FirebaseFirestore.instance
            .collection("chatGroups")
            .doc(widget.chatGroup.chatRoomId)
            .update({"lastMsgTime": data.createdOn, "lastMsg": "Photo"});
      });
    }
  }

  updateUnreadMsg() async {
    List uploadData = [];
    for (Map e in widget.chatGroup.unreadMsg!) {
      e.forEach((key, value) {
        if (key.toString() != widget.currentUser.id.toString()) {
          uploadData.add({key: value});
        }
        if (key.toString() == widget.currentUser.id.toString()) {
          uploadData.add({key: 0});
        }
      });
    }
    await FirebaseFirestore.instance
        .collection("chatGroups")
        .doc(widget.chatGroup.chatRoomId.toString())
        .update({"unreadMsg": uploadData});
  }

  Future<void> fetchFriendsDetails() async {
    for (var e in widget.chatGroup.participants!) {
      var user = await FirebaseFirestore.instance.collection("users").doc(e.toString()).get();
      var model = UserModel.fromJson(user.data() as Map<String, dynamic>);
      participantData.add(model);
      participantsName[model.id.toString()] = model.name.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("user data$participantData");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 65,
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
              backgroundImage: widget.chatGroup.groupProfile != "" && widget.chatGroup.groupProfile != null
                  ? NetworkImage(widget.chatGroup.groupProfile.toString())
                  : null,
              child: IconButton(
                  onPressed: () {},
                  icon: widget.chatGroup.groupProfile != "" && widget.chatGroup.groupProfile != null
                      ? Container()
                      : const Icon(
                    Icons.group,
                    color: Colors.white,
                  )),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatGroup.groupName.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  Text(
                    participantsName.values.toString(),
                    style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.fade,
                  )
                ],
              ),
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
                                    .collection("chatGroups")
                                    .doc(widget.chatGroup.chatRoomId.toString())
                                    .collection("messages")
                                    .get()
                                    .then((value) {
                                  for (var docs in value.docs) {
                                    docs.reference.delete();
                                  }
                                }).then((value) async {
                                  await FirebaseStorage.instance
                                      .ref(widget.chatGroup.chatRoomId.toString())
                                      .listAll()
                                      .then((value) {
                                    for (var element in value.items) {
                                      element.delete();
                                    }
                                  }).then((value) async {
                                    Navigator.pop(context);
                                    await FirebaseFirestore.instance
                                        .collection("chatGroups")
                                        .doc(widget.chatGroup.chatRoomId.toString())
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
          children: [
            Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatGroups")
                      .doc(widget.chatGroup.chatRoomId.toString())
                      .collection("messages")
                      .orderBy("createdOn", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.isNotEmpty) {
                        allMsg = snapshot.data!.docs.map((e) {
                          return MessageModel.fromJson(e.data());
                        }).toList();

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            reverse: true,
                            itemCount: allMsg.length,
                            itemBuilder: (context, index) {
                              prevMsg = currentMsg;
                              showUserName = false;
                              currentMsg = allMsg[index];
                              if (prevMsg != null) {
                                print("prev msg  ${prevMsg!.msg}  ${prevMsg!.senderId}");
                                print("curr msg  ${currentMsg!.msg}  ${currentMsg!.senderId}");
                                if (currentMsg!.senderId != prevMsg!.senderId) {
                                  showUserName = true;
                                }
                              }
                              if (index == allMsg.length - 1) {
                                prevMsg = null;
                              }
                              print(showUserName.toString());

                              if (allMsg[index].msgType == "text") {
                                return Column(children: [
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                      mainAxisAlignment: allMsg[index].senderId.toString() == widget.currentUser.id.toString()
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        LimitedBox(
                                          maxWidth: 320,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                                            decoration: BoxDecoration(
                                                borderRadius: allMsg[index].senderId == widget.currentUser.id
                                                    ? const BorderRadius.only(
                                                    bottomRight: Radius.circular(15),
                                                    topRight: Radius.zero,
                                                    topLeft: Radius.circular(15),
                                                    bottomLeft: Radius.circular(15))
                                                    : const BorderRadius.only(
                                                    bottomRight: Radius.circular(15),
                                                    topRight: Radius.circular(15),
                                                    topLeft: Radius.zero,
                                                    bottomLeft: Radius.circular(15)),
                                                color: allMsg[index].senderId.toString() == widget.currentUser.id.toString()
                                                    ? const Color(0xFFb3f2c7)
                                                    : const Color(0xFFa8e5f0)),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                LimitedBox(
                                                  maxWidth: 240,
                                                  child: Text(allMsg[index].msg.toString(),
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${allMsg[index].createdOn!.toDate().hour}:${(allMsg[index]
                                                      .createdOn!
                                                      .toDate()
                                                      .minute).toString().padLeft(2, "0")}",
                                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                                ),
                                                Icon(Icons.check,
                                                    color: allMsg[index].seen == true ? Colors.blue : Colors.grey, size: 17)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                  participantsName[allMsg[index].senderId.toString()] !=
                                      participantsName[widget.currentUser.id.toString()]
                                      ? (showUserName
                                      ? const SizedBox(
                                    height: 10,
                                  )
                                      : Container())
                                      : Container(),

                                  // participantsName[allMsg[index].senderId.toString()] !=
                                  //     participantsName[widget.currentUser.id.toString()] ?
                                  prevMsg != null
                                      ? Row(
                                    mainAxisAlignment: prevMsg!.senderId.toString() == widget.currentUser.id
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      showUserName
                                          ? Text(
                                        participantsName[prevMsg!.senderId.toString()].toString(),
                                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                                      )
                                          : Container(),
                                    ],
                                  )
                                      : Container()
                                ]);
                              } else if (allMsg[index].msgType == "img") {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: allMsg[index].senderId == widget.currentUser.id
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 3),
                                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                                      decoration: BoxDecoration(
                                          color: allMsg[index].senderId == widget.currentUser.id
                                              ? const Color(0xFFb3f2c7)
                                              : const Color(0xFFa8e5f0),
                                          borderRadius: allMsg[index].senderId == widget.currentUser.id
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          LimitedBox(
                                            maxWidth: MediaQuery
                                                .of(context)
                                                .size
                                                .width / 2,
                                            maxHeight: MediaQuery
                                                .of(context)
                                                .size
                                                .height / 3,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ShowGroupImage(imgUrl: allMsg[index].msg.toString()),
                                                    ));
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: CachedNetworkImage(
                                                  imageUrl: allMsg[index].msg.toString(),
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                        color: Colors.grey,
                                                        child: const Center(child: CircularProgressIndicator()),
                                                      ),
                                                  errorWidget: (context, url, error) {
                                                    if(url == "dummy data"){
                                                      return Container(
                                                        color: Colors.grey,
                                                        child: const Center(child: CircularProgressIndicator()),
                                                      );
                                                    }else{
                                                      return const Text(" ** An error Occurred while Loading Img **",style: TextStyle(fontStyle: FontStyle.italic),);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${allMsg[index].createdOn!.toDate().hour}:${(allMsg[index]
                                                    .createdOn!
                                                    .toDate()
                                                    .minute).toString().padLeft(2, "0")}",
                                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                              ),
                                              Icon(Icons.check,
                                                  color: allMsg[index].seen == true ? Colors.blue : Colors.grey, size: 17),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        );
                      } else {
                        return const Text("Start Chatting with Friends");
                      }
                    } else if (snapshot.hasError) {
                      return const Text("An Error Occurred");
                    } else {
                      return const Text("Start Chatting with Friends");
                    }
                  },
                )),
            // *********************  BOTTOM TYPING BAR  *************************************
            Container(
              margin: const EdgeInsets.all(5),
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
                          onPressed: () async {
                            if (msgController.text.isNotEmpty) {
                              String msg = msgController.text;
                              msgController.clear();
                              msgDetails = MessageModel(
                                  msg: msg,
                                  msgId: uuid.v1(),
                                  senderId: widget.currentUser.id,
                                  createdOn: Timestamp.now(),
                                  seen: false,
                                  msgType: "text");
                              if (msgDetails != null) {
                                FirebaseFirestore.instance
                                    .collection("chatGroups")
                                    .doc(widget.chatGroup.chatRoomId.toString())
                                    .collection("messages")
                                    .doc(msgDetails!.msgId.toString())
                                    .set(msgDetails!.toMap());

                                Map<String, dynamic> uploadData = {
                                  "lastMsg": msg,
                                  "lastMsgTime": msgDetails!.createdOn,
                                  "unreadMsg": await unreadMsgIncrement()
                                };

                                FirebaseFirestore.instance
                                    .collection("chatGroups")
                                    .doc(widget.chatGroup.chatRoomId.toString())
                                    .update(uploadData);
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
      ),
    );
  }

  Future<List<Map<String, dynamic>>> unreadMsgIncrement() async {
    List<Map<String, dynamic>> unreadMsg = [];

    var data = await FirebaseFirestore.instance.collection("chatGroups").doc(widget.chatGroup.chatRoomId).get();
    List temp = data.data()!["unreadMsg"];

    for (Map e in temp) {
      e.forEach((key, value) {
        if (key.toString() != widget.currentUser.id) {
          unreadMsg.add({key.toString(): value + 1});
        }
        if (key.toString() == widget.currentUser.id) {
          unreadMsg.add({key.toString(): value});
        }
      });
    }
    return unreadMsg;
  }
}

class ShowGroupImage extends StatelessWidget {
  final String imgUrl;

  const ShowGroupImage({required this.imgUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            top: true,
            bottom: true,
            child: Center(
                child: InteractiveViewer(
                  child: Image.network(imgUrl),
                ))));
  }
}
