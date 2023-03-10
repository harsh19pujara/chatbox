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

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {

                  },
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatGroup.groupName.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 22),
                ),
                Text(
                  widget.chatGroup.participants.toString(),
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
            Expanded(child: StreamBuilder(builder: (context, snapshot) {
return Container();
            },)),
            Container(
              // height: 60,
              margin: const EdgeInsets.all(5),
              // color: Colors.red,
              // padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
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

                                // print("msg send  ++++++++++++++++++++++++++++++++++++:::::::::::::::::::::");
                                // print(widget.chatRoom.lastMsg);
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
