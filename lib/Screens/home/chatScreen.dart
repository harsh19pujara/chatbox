import 'package:chatting_app/Model/chatModel.dart';
import 'package:chatting_app/Model/messageModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/profileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  @override
  void initState() {
    super.initState();
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
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userData: widget.currentUser, searchedUser: widget.searchedUser),
                          ));
                    },
                    icon: const Icon(Icons.person)),
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
                  }).then((value) {
                    FirebaseFirestore.instance
                        .collection("chatRooms")
                        .doc(widget.chatRoom.chatRoomId.toString())
                        .update({"lastMsg": ""});
                  });
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
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatRooms")
                      .doc(widget.chatRoom.chatRoomId.toString())
                      .collection("messages")
                      .orderBy("createdOn", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        // height: MediaQuery.of(context).size.height - 180,
                        // width: MediaQuery.of(context).size.width - 10,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Container(
                              // color: Colors.blueGrey,
                              width: MediaQuery.of(context).size.width - 100,
                              child: Row(
                                  mainAxisAlignment:
                                      snapshot.data!.docs[index].data()["senderId"].toString() == widget.currentUser.id
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  children: [
                                    LimitedBox(
                                      maxWidth: 300,
                                      child: Container(
                                          margin: const EdgeInsets.symmetric(vertical: 3),
                                          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                                          decoration: BoxDecoration(
                                              color: snapshot.data!.docs[index].data()["senderId"].toString() ==
                                                      widget.currentUser.id
                                                  ? const Color(0xFFb3f2c7)
                                                  : const Color(0xFFa8e5f0),
                                              borderRadius: snapshot.data!.docs[index].data()["senderId"].toString() ==
                                                      widget.currentUser.id
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
                                          child: Text(
                                            snapshot.data!.docs[index].data()["msg"],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                color: snapshot.data!.docs[index].data()["senderId"].toString() ==
                                                        widget.currentUser.id
                                                    ? Colors.black
                                                    : Colors.black),
                                            softWrap: true,
                                            maxLines: null,
                                            textAlign:
                                                snapshot.data!.docs[index].data()["senderId"].toString() == widget.currentUser.id
                                                    ? TextAlign.start
                                                    : TextAlign.start,
                                          )),
                                    )
                                  ]),
                            );
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text("Please Check Your Internet Connection");
                    } else {
                      return const Text("Say Hii to Your Friend");
                    }
                  },
                ),
              ),
              Container(
                // height: 60,
                margin: const EdgeInsets.all(5),
                // color: Colors.red,
                // padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {},
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
                        textCapitalization: TextCapitalization.words,
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
                                    seen: false);
                                if (msgDetails != null) {
                                  FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(widget.chatRoom.chatRoomId.toString())
                                      .collection("messages")
                                      .doc(msgDetails!.msgId.toString())
                                      .set(msgDetails!.toMap());

                                  print("msg send          ++++++++++++++++++++++++++++++++++++::::;:::::::::::::::::");

                                  widget.chatRoom.lastMsg = msgController.text.toString();
                                  widget.chatRoom.lastMsgTime = msgDetails!.createdOn;
                                  print(widget.chatRoom.lastMsg);
                                  FirebaseFirestore.instance
                                      .collection("chatRooms")
                                      .doc(widget.chatRoom.chatRoomId.toString())
                                      .set(widget.chatRoom.toMap());
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
