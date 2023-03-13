import 'package:chatting_app/Model/chatGroupModel.dart';
import 'package:chatting_app/Model/messageModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/profileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
  List<UserModel> participantData = [];
  Map<String, String> participantsName = {};

  @override
  void initState() {
    fetchFriendsDetails().then((value) {
      setState(() {});
    });
    super.initState();
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
    print("user data" + participantData.toString());
    return Scaffold(
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
                                // await FirebaseFirestore.instance
                                //     .collection("chatGroups")
                                //     .doc(widget.chatGroup.chatRoomId.toString())
                                //     .collection("messages")
                                //     .get()
                                //     .then((value) {
                                //   for (var docs in value.docs) {
                                //     docs.reference.delete();
                                //   }
                                // }).then((value) async {
                                //   await FirebaseStorage.instance
                                //       .ref(widget.chatGroup.chatRoomId.toString())
                                //       .listAll()
                                //       .then((value) {
                                //     for (var element in value.items) {
                                //       element.delete();
                                //     }
                                //   }).then((value) async {
                                //     Navigator.pop(context);
                                //     await FirebaseFirestore.instance
                                //         .collection("chatRooms")
                                //         .doc(widget.chatGroup.chatRoomId.toString())
                                //         .update({"lastMsg": ""});
                                //   });
                                // });
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
                    List<MessageModel> allMsg = snapshot.data!.docs.map((e) {
                      return MessageModel.fromJson(e.data());
                    }).toList();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: allMsg.length,
                        itemBuilder: (context, index) {
                          return Column(children: [
                            const SizedBox(
                              height: 5,
                            ),
                            participantsName[allMsg[index].senderId.toString()] !=
                                    participantsName[widget.currentUser.id.toString()]
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        participantsName[allMsg[index].senderId.toString()].toString(),
                                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                : Container(),
                            Row(
                                mainAxisAlignment: allMsg[index].senderId.toString() == widget.currentUser.id.toString()
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  LimitedBox(
                                    maxWidth: 280,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 3),
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
                                      child: SizedBox(
                                        child: Text(allMsg[index].msg.toString(),
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                                      ),
                                    ),
                                  ),
                                ]),
                            Row(
                              mainAxisAlignment: allMsg[index].senderId.toString() == widget.currentUser.id.toString()
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${allMsg[index].createdOn!.toDate().hour}:${allMsg[index].createdOn!.toDate().minute}",
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                                Icon(Icons.check, color: allMsg[index].seen == true ? Colors.blue : Colors.grey, size: 17)
                              ],
                            )
                          ]);
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
                        // openImagePicker();
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
                                    .collection("chatGroups")
                                    .doc(widget.chatGroup.chatRoomId.toString())
                                    .collection("messages")
                                    .doc(msgDetails!.msgId.toString())
                                    .set(msgDetails!.toMap());

                                FirebaseFirestore.instance
                                    .collection("chatGroups")
                                    .doc(widget.chatGroup.chatRoomId.toString())
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
      ),
    );
  }
}
