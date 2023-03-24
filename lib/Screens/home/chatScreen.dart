import 'dart:io';

import 'package:chatting_app/Helper/themes.dart';
import 'package:chatting_app/Model/chatModel.dart';
import 'package:chatting_app/Model/messageModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/profileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.chatRoom, required this.currentUser, required this.searchedUser}) : super(key: key);
  final ChatModel chatRoom;
  final UserModel currentUser;
  final UserModel? searchedUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final uuid = const Uuid();
  MessageModel? msgDetails;
  TextEditingController msgController = TextEditingController();
  File? chatFile;
  File? thumbFile;
  bool doReply = false;
  String replyMsg = '';

  @override
  void initState() {
    updateUserOnlineStatus(true);
    super.initState();
  }

  updateUserOnlineStatus(bool status) async {
    await FirebaseFirestore.instance
        .collection("chatRooms")
        .doc(widget.chatRoom.chatRoomId)
        .update({"online.${widget.currentUser.id.toString()}": status, "unreadMsg.${widget.currentUser.id.toString()}": 0});
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
    String msgType = '';
    var file = await FilePicker.platform.pickFiles();
    if (file != null) {
      String path = file.files.single.path!;
      chatFile = File(path);
      String extension = path.trim().split(".").last;
      print("extension  " + extension);

      if (extension == "jpg" || extension == "png") {
        msgType = "img";
      } else if (extension == "mp4") {
        msgType = "video";
        final thumbData = await VideoThumbnail.thumbnailFile(video: path, imageFormat: ImageFormat.PNG, quality: 80);
        thumbFile = File(thumbData.toString());
      } else if (extension == "pdf") {
        msgType = "pdf";
      } else {
        msgType = "random";
      }

      var data = MessageModel(
        msgType: msgType,
        msg: "dummy data",
        msgId: uuid.v1(),
        senderId: widget.currentUser.id,
        createdOn: Timestamp.now(),
        seen: false,
      );

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoom.chatRoomId.toString())
          .collection("messages")
          .doc(data.msgId)
          .set(data.toMap())
          .then((value) {
        uploadFile(data: data);
      });
    }
  }

  uploadFile({required MessageModel data}) async {
    TaskSnapshot uploadedThumbnail;
    Map<String, dynamic> chatBoxData = {};

    var uploadedFile =
        await FirebaseStorage.instance.ref(widget.chatRoom.chatRoomId.toString()).child(data.msgId.toString()).putFile(chatFile!);
    String urlFile = await uploadedFile.ref.getDownloadURL();
    Map<String, dynamic> sendData = {"msg": urlFile};
    print("file done");

    if (data.msgType == "img") {
      chatBoxData = {"lastMsgTime": data.createdOn, "lastMsg": "Photo"};
    } else if (data.msgType == "video") {
      print("thumb uploading");
      uploadedThumbnail = await FirebaseStorage.instance
          .ref(widget.chatRoom.chatRoomId.toString())
          .child("Thumbnails")
          .child(data.msgId.toString())
          .putFile(thumbFile!);
      print("thumb uploaded");
      String urlThumb = await uploadedThumbnail.ref.getDownloadURL();
      print("url generated");
      sendData["thumbnail"] = urlThumb;
      chatBoxData = {"lastMsgTime": data.createdOn, "lastMsg": "Video"};
    } else {
      chatBoxData = {"lastMsgTime": data.createdOn, "lastMsg": "Unknown Data"};
    }

    if (urlFile.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoom.chatRoomId.toString())
          .collection("messages")
          .doc(data.msgId)
          .update(sendData)
          .then((value) async {
        await FirebaseFirestore.instance.collection("chatRooms").doc(widget.chatRoom.chatRoomId).update(chatBoxData);
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
                backgroundColor: CustomColor.friendColor,
                backgroundImage: widget.searchedUser!.profile != "" && widget.searchedUser!.profile != null
                    ? NetworkImage(widget.searchedUser!.profile.toString())
                    : null,
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(searchedUser: widget.searchedUser!),
                          ));
                    },
                    icon: widget.searchedUser!.profile != "" && widget.searchedUser!.profile != null
                        ? Container()
                        : const Icon(
                            Icons.person,
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
                      widget.searchedUser!.name.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      widget.searchedUser!.email.toString(),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
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
                        title: Text(
                          "Do you want to Delete All Chats and Photos ? ",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancel",
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18),
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
                                    await FirebaseStorage.instance
                                        .ref(widget.chatRoom.chatRoomId.toString())
                                        .listAll()
                                        .then((value) {
                                      for (var element in value.items) {
                                        element.delete();
                                      }
                                    }).then((value) async {
                                      Navigator.pop(context);
                                      await FirebaseFirestore.instance
                                          .collection("chatRooms")
                                          .doc(widget.chatRoom.chatRoomId.toString())
                                          .update({
                                        "lastMsg": "",
                                        "unreadMsg.${widget.searchedUser!.id.toString()}": 0,
                                        "unreadMsg.${widget.currentUser.id.toString()}": 0
                                      });
                                    });
                                  });
                                },
                                child: Text("Delete",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: CustomColor.unreadMsg, fontSize: 18)))
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
                /// ************* CHECKING FRIEND ONLINE STATUS  ******************
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              reverse: true,
                              itemCount: messageList.length,
                              itemBuilder: (context, index) {
                                if (chatRoomSnapshot.hasData) {
                                  if (messageList[index].senderId.toString() != widget.currentUser.id.toString()) {
                                    bool isOnline = chatRoomSnapshot.data!["online"][widget.currentUser.id];
                                    if (isOnline == true && messageList[index].seen == false) {
                                      updateMessageOnlineStatus(messageList[index].msgId.toString(), true);
                                    }
                                  }
                                }

                                ///*************************   SHOW TEXT IN CHAT   *******************************
                                if (messageList[index].msgType == "text") {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    dismissThresholds: messageList[index].senderId == widget.currentUser.id
                                        ? const {DismissDirection.endToStart: 0.5}
                                        : const {DismissDirection.startToEnd: 0.5},
                                    onUpdate: (details) {
                                      if (details.reached) {
                                        setState(() {
                                          doReply = true;
                                          replyMsg = messageList[index].msg.toString();
                                        });
                                      }
                                    },
                                    child: SizedBox(
                                      // color: Colors.blueGrey,
                                      width: MediaQuery.of(context).size.width - 100,
                                      child: Row(
                                          mainAxisAlignment: messageList[index].senderId == widget.currentUser.id
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: const EdgeInsets.symmetric(vertical: 1.5),
                                                padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
                                                decoration: BoxDecoration(
                                                    color: messageList[index].senderId == widget.currentUser.id
                                                        ? CustomColor.userColor
                                                        : CustomColor.friendColor,
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
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    messageList[index].repliedTo != '' && messageList[index].repliedTo != null
                                                        ? Container(  /// SHOW REPLIED MESSAGE TEXT
                                                            constraints:
                                                                const BoxConstraints(maxWidth: 280, maxHeight: 100, minWidth: 80),
                                                            padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                                            margin: const EdgeInsets.only(bottom: 5),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: const Color(0xFFeaf7e4),
                                                              border: Border.all(width: 0.1),
                                                            ),
                                                            child: Text(
                                                              messageList[index].repliedTo!,
                                                              overflow: TextOverflow.fade,
                                                            ),
                                                          )
                                                        : Container(),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        LimitedBox(
                                                          maxWidth: 240,
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
                                                            style: Theme.of(context).textTheme.bodyMedium,
                                                            softWrap: true,
                                                            maxLines: null,
                                                            linkifiers: const [EmailLinkifier(), UrlLinkifier()],
                                                            linkStyle: const TextStyle(color: Colors.blueAccent),
                                                            textAlign: TextAlign.start,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "${messageList[index].createdOn!.toDate().hour}:${(messageList[index].createdOn!.toDate().minute).toString().padLeft(2, "0")}",
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(fontStyle: FontStyle.italic),
                                                        ),
                                                        messageList[index].senderId == widget.currentUser.id
                                                            ? (Icon(Icons.check,
                                                                color:
                                                                    messageList[index].seen == true ? Colors.blue : Colors.grey,
                                                                size: 17))
                                                            : const SizedBox(
                                                                width: 2,
                                                              )
                                                      ],
                                                    ),
                                                  ],
                                                ))
                                          ]),
                                    ),
                                  );
                                }

                                /// ****************** SHOW IMAGES IN CHAT *********************
                                else if (messageList[index].msgType == "img") {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    dismissThresholds: messageList[index].senderId == widget.currentUser.id
                                        ? const {DismissDirection.endToStart: 0.5}
                                        : const {DismissDirection.startToEnd: 0.5},
                                    onUpdate: (details) {
                                      if (details.reached) {
                                        setState(() {
                                          doReply = true;
                                          replyMsg = messageList[index].msg.toString();
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: messageList[index].senderId == widget.currentUser.id
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 3),
                                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              LimitedBox(
                                                maxWidth: MediaQuery.of(context).size.width / 1.5,
                                                maxHeight: MediaQuery.of(context).size.height / 2.5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ShowImage(imgUrl: messageList[index].msg.toString()),
                                                        ));
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: CachedNetworkImage(
                                                        imageUrl: messageList[index].msg.toString(),
                                                        fit: BoxFit.fill,
                                                        placeholder: (context, url) => Container(
                                                              color: Colors.grey,
                                                              child: const Center(child: CircularProgressIndicator()),
                                                            ),
                                                        errorWidget: (context, url, error) {
                                                          if (url == "dummy data") {
                                                            return Container(
                                                              color: Colors.grey,
                                                              child: const Center(child: CircularProgressIndicator()),
                                                            );
                                                          } else {
                                                            return Text(
                                                              " ** An error Occurred while Loading Img **",
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(fontStyle: FontStyle.italic),
                                                            );
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${messageList[index].createdOn!.toDate().hour}:${(messageList[index].createdOn!.toDate().minute).toString().padLeft(2, "0")}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(fontStyle: FontStyle.italic),
                                                  ),
                                                  messageList[index].senderId == widget.currentUser.id
                                                      ? (Icon(Icons.check,
                                                          color: messageList[index].seen == true ? Colors.blue : Colors.grey,
                                                          size: 17))
                                                      : const SizedBox(
                                                          width: 4,
                                                        )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  /// ****************** SHOW VIDEOS IN CHAT *********************
                                } else if (messageList[index].msgType == "video") {
                                  return Dismissible(
                                    key: UniqueKey(),
                                    dismissThresholds: messageList[index].senderId == widget.currentUser.id
                                        ? const {DismissDirection.endToStart: 0.5}
                                        : const {DismissDirection.startToEnd: 0.5},
                                    onUpdate: (details) {
                                      if (details.reached) {
                                        setState(() {
                                          doReply = true;
                                          replyMsg = messageList[index].msg.toString();
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: messageList[index].senderId == widget.currentUser.id
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(vertical: 3),
                                          padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              LimitedBox(
                                                maxWidth: MediaQuery.of(context).size.width / 1.5,
                                                maxHeight: MediaQuery.of(context).size.height / 2.5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PlayVideo(videoUrl: messageList[index].msg.toString()),
                                                        ));
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(6),
                                                    child: CachedNetworkImage(
                                                        imageUrl: messageList[index].thumbnail.toString(),
                                                        fit: BoxFit.fill,
                                                        placeholder: (context, url) => Container(
                                                              color: Colors.grey,
                                                              child: const Center(child: CircularProgressIndicator()),
                                                            ),
                                                        errorWidget: (context, url, error) {
                                                          if (url == "dummy data") {
                                                            return Container(
                                                              color: Colors.grey,
                                                              child: const Center(child: CircularProgressIndicator()),
                                                            );
                                                          } else {
                                                            return Text(
                                                              " ** An error Occurred while Loading Video **",
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(fontStyle: FontStyle.italic),
                                                            );
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${messageList[index].createdOn!.toDate().hour}:${(messageList[index].createdOn!.toDate().minute).toString().padLeft(2, "0")}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(fontStyle: FontStyle.italic),
                                                  ),
                                                  messageList[index].senderId == widget.currentUser.id
                                                      ? (Icon(Icons.check,
                                                          color: messageList[index].seen == true ? Colors.blue : Colors.grey,
                                                          size: 17))
                                                      : const SizedBox(
                                                          width: 4,
                                                        )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  /// ****************** SHOW PDF IN CHAT *********************
                                } else if (messageList[index].msgType == "pdf") {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: messageList[index].senderId == widget.currentUser.id
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: const [
                                      Text("pdf Data"),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: messageList[index].senderId == widget.currentUser.id
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: const [
                                      Text("Random Data"),
                                    ],
                                  );
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

              ///****************   BOTTOM TEXT FIELD, SEND FILES   ************************
              Container(
                // height: 60,
                margin: const EdgeInsets.only(top: 0, bottom: 2, left: 3, right: 3),
                // color: Colors.red,
                // padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                decoration: BoxDecoration(
                    color: doReply ? CustomColor.userColor : null, borderRadius: const BorderRadius.all(Radius.circular(15))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          doReply
                              ? Container(
                                  height: 60,
                                  width: 236,
                                  padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFeaf7e4),
                                    border: Border.all(width: 0.1),
                                  ),
                                  child: Text(replyMsg, style: const TextStyle(), overflow: TextOverflow.fade),
                                )
                              : Container(),
                          Flexible(
                              child: LimitedBox(
                            maxHeight: 70,
                            child: SizedBox(
                              width: 236,
                              child: TextField(
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),
                                controller: msgController,
                                textCapitalization: TextCapitalization.sentences,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                    focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        borderSide: BorderSide(color: Colors.transparent)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    filled: true,
                                    fillColor: Colors.black12,
                                    hintText: "Enter Text...",
                                    hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.blueGrey),
                                    enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        borderSide: BorderSide(color: Colors.transparent))),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF20A090),
                        radius: 25,
                        child: IconButton(
                            onPressed: () {
                              sendMessage();
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

  Future<int> messageIncrement() async {
    var chatData = await FirebaseFirestore.instance.collection("chatRooms").doc(widget.chatRoom.chatRoomId).get();
    var count = chatData.data()!["unreadMsg"][widget.searchedUser!.id.toString()];
    // print("count" + count.toString());
    var data = count;
    if (chatData.data()!["online"][widget.searchedUser!.id.toString()] == false) {
      data = count + 1;
    }
    print("msg count increment" + data.toString());

    return data;
  }

  sendMessage() {
    if (msgController.text.isNotEmpty) {
      String currentMsg = msgController.text;
      msgController.clear();
      msgDetails = MessageModel(
          msg: currentMsg,
          msgId: uuid.v1(),
          senderId: widget.currentUser.id,
          createdOn: Timestamp.now(),
          seen: false,
          msgType: "text",
          repliedTo: replyMsg);

      setState(() {
        replyMsg = '';
        doReply = false;
      });

      if (msgDetails != null) {
        FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(widget.chatRoom.chatRoomId.toString())
            .collection("messages")
            .doc(msgDetails!.msgId.toString())
            .set(msgDetails!.toMap())
            .then((value) async {
          var updateData = {
            "lastMsg": currentMsg,
            "lastMsgTime": msgDetails!.createdOn,
            "unreadMsg.${widget.searchedUser!.id.toString()}": await messageIncrement()
          };

          await FirebaseFirestore.instance.collection("chatRooms").doc(widget.chatRoom.chatRoomId.toString()).update(updateData);
        });
      }
    }
  }
}

class ShowImage extends StatelessWidget {
  final String imgUrl;

  const ShowImage({required this.imgUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          top: true,
          bottom: true,
          child: Center(
              child: InteractiveViewer(
                  maxScale: double.infinity,
                  clipBehavior: Clip.none,
                  boundaryMargin: const EdgeInsets.all(0),
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    placeholder: (context, url) {
                      return const Center(
                        child: LinearProgressIndicator(),
                      );
                    },
                  )))),
    );
  }
}

class PlayVideo extends StatefulWidget {
  const PlayVideo({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;
  String position = '';
  String duration = '';
  double currentVolume = 0.5;

  @override
  void initState() {
    print("in init");
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() {
      setState(() {
        position = _controller.value.position.toString().trim().split('.').first;
      });
    })
      ..initialize().then((value) {
        if (mounted) {
          setState(() {
            duration = _controller.value.duration.toString().split('.').first;
          });
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(
                    _controller,
                  ),
                )
              : const Center(child: Text("Loading...")),
          // SizedBox(height: 10,),
          if(_controller.value.isInitialized)...[
              VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                    setState(() {});
                  },
                  icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow,)),
              Text("$position/$duration",style: TextStyle(fontSize: 14),),
              SizedBox(width: 32,),
              customVolumeIcon(),
              SizedBox(
                width: 160,
                child: Slider(value: currentVolume, onChanged: (value) {
                  setState(() {
                    currentVolume = value;
                    _controller.setVolume(value);

                  });
                },max: 1,min: 0,),
              ),

            ],
          )]
        ],
      ),
    );
  }

  Widget customVolumeIcon(){
    return Icon(Icons.volume_up_sharp, size: 20,);
  }
}
