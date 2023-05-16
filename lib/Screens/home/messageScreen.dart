import 'package:chatting_app/Helper/privacy.dart';
import 'package:chatting_app/Helper/themes.dart';
import 'package:chatting_app/Model/chatGroupModel.dart';
import 'package:chatting_app/Model/chatModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/chatScreen.dart';
import 'package:chatting_app/Screens/home/groupChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key, required this.userData}) : super(key: key);
  final UserModel userData;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with WidgetsBindingObserver {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = true;
  bool stopSlide = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          FirebaseFirestore.instance.collection("users").doc(widget.userData.id.toString()).update({"isOnline": true});
        });
      }
    } else {
      if (mounted) {
        setState(() {
          FirebaseFirestore.instance.collection("users").doc(widget.userData.id.toString()).update({"isOnline": false});
        });
      }
    }
  }

  Future<bool> holdDismiss() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              return index == 0 ? ownStory('assets/images/dp1.png') : storyWidget('assets/images/dp2.png');
            },
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatRooms")
                      .where("participants", arrayContains: widget.userData.id.toString())
                      .orderBy("lastMsgTime", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData || snapshot.hasError) {
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("chatGroups")
                            .where("participants", arrayContains: widget.userData.id.toString())
                            .orderBy("lastMsgTime", descending: true)
                            .snapshots(),
                        builder: (context, groupSnapshot) {
                          if (snapshot.data!.docs.isNotEmpty) {
                            // modeling personal chats into custom map data
                            List<Map<String, dynamic>> groupChatList = [];
                            List<Map<String, dynamic>> personalChatList = [];
                            List<Map> allRecentChatList = [];

                            personalChatList = snapshot.data!.docs
                                .map((e) {
                                  var personalChatModel = ChatModel.fromJson(e.data());
                                  if (personalChatModel.lastMsg != "" || personalChatModel.lastMsgTime != null) {
                                    Map<String, dynamic> mapData = {
                                      "data": personalChatModel,
                                      "time": personalChatModel.lastMsgTime!.toDate(),
                                      "type": "personalChat"
                                    };
                                    allRecentChatList.add(mapData);
                                    return mapData;
                                  }
                                })
                                .whereType<Map<String, dynamic>>()
                                .toList();

                            if (groupSnapshot.hasData) {
                              if (groupSnapshot.data!.docs.isNotEmpty) {
                                groupChatList = groupSnapshot.data!.docs.map((e) {
                                  var groupChatModel = ChatGroupModel.fromJson(e.data());
                                  Map<String, dynamic> mapData = {
                                    "data": groupChatModel,
                                    "time": groupChatModel.lastMsgTime!.toDate(),
                                    "type": "groupChat"
                                  };
                                  allRecentChatList.add(mapData);
                                  return mapData;
                                }).toList();
                              }
                            }

                            allRecentChatList.sort((b, a) {
                              DateTime aTime = a["time"];
                              DateTime bTime = b["time"];
                              return aTime.compareTo(bTime);
                            });

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: allRecentChatList.length,
                              itemBuilder: (context, index) {
                                // if (isLoading == true) {
                                //   if (allRecentChatList[index]["data"] ==
                                //       allRecentChatList[allRecentChatList.length - 1]["data"]) {
                                //     print("loading false");
                                //     if (mounted) {
                                //
                                //     }
                                //   }
                                // }

                                if (allRecentChatList[index]["type"] == "personalChat") {
                                  return recentChatWidget(allRecentChatList[index]["data"]);
                                } else if (allRecentChatList[index]["type"] == "groupChat") {
                                  return recentGroupWidget(allRecentChatList[index]["data"]);
                                } else {
                                  return const Text("Type Error");
                                }
                              },
                            );
                          } else if (snapshot.hasError) {
                            return const Center(child: Text("Error Fetching Data", style: TextStyle(fontSize: 18)));
                          } else {
                            return const Center(child: Text("Start Chatting With Friends", style: TextStyle(fontSize: 18)));
                          }
                        },
                      );
                    } else {
                      return const Center(
                          child: Text(
                        "Start Chatting With Friends",
                        style: TextStyle(fontSize: 18),
                      ));
                    }
                  },
                ),
              ),
              isLoading ? const Center(child: CircularProgressIndicator()) : Container(),
            ],
          ),
        )
      ],
    );
  }

  Widget storyWidget(String img) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: CircleAvatar(
          backgroundImage: AssetImage(img),
          radius: 27,
        ),
      ),
    );
  }

  Widget recentChatWidget(ChatModel data) {
    String? otherUser;
    List<UserModel> searchedUserList = [];

    for (var element in data.participants!) {
      if (element.toString() != widget.userData.id.toString()) {
        otherUser = element;
      }
    }
    return StreamBuilder(
      /// Stream builder for continuous online offline status of user
      stream: FirebaseFirestore.instance.collection("users").doc(otherUser).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          UserModel searchedUser = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          String lastMsgTime = showTime(data.lastMsgTime!.toDate());

          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(chatRoom: data, currentUser: widget.userData, searchedUser: searchedUser),
                  ));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 70,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Stack(children: [
                      CircleAvatar(
                        backgroundColor: CustomColor.friendColor,
                        backgroundImage: searchedUser.profile != "" && searchedUser.profile != null
                            ? NetworkImage(searchedUser.profile.toString())
                            : null,
                        radius: 26,
                        child: searchedUser.profile != "" && searchedUser.profile != null
                            ? null
                            : const Icon(Icons.person, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 3,
                        right: 3,
                        child: Container(
                          height: 10,
                          width: 10,
                          // alignment: AlignmentDirectional.bottomEnd,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: searchedUser.isOnline != null
                                  ? (searchedUser.isOnline! ? CustomColor.online : CustomColor.offline)
                                  : CustomColor.unreadMsg),
                        ),
                      )
                    ]),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            searchedUser.name.toString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Text(
                            data.lastMsgTime!.compareTo(Timestamp.fromDate(DateTime.parse("2023-05-15"))) >= 0 ?
                            MessagePrivacy.decryption(data.lastMsg.toString().trim()).replaceAll('\n', ' ')
                              : data.lastMsg.toString().trim().replaceAll('\n', ' '),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            lastMsgTime,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          data.unreadMsg![widget.userData.id.toString()] == 0
                              ? Container()
                              : CircleAvatar(
                                  radius: 12,
                                  backgroundColor: CustomColor.unreadMsg,
                                  child: Text(data.unreadMsg![widget.userData.id.toString()].toString()),
                                )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget recentGroupWidget(ChatGroupModel data) {
    String lastMsgTime = showTime(data.lastMsgTime!.toDate());
    int unreadMsg = 0;
    for (Map e in data.unreadMsg!) {
      e.forEach((key, value) {
        if (key.toString() == widget.userData.id.toString()) {
          unreadMsg = value;
        }
      });
    }

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => GroupChat(chatGroup: data, currentUser: widget.userData)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 70,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: CustomColor.friendColor,
                backgroundImage:
                    data.groupProfile != "" && data.groupProfile != null ? NetworkImage(data.groupProfile.toString()) : null,
                radius: 26,
                child:
                    data.groupProfile != "" && data.groupProfile != null ? null : const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.groupName.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      data.lastMsg.toString().replaceAll('\n', ' '),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 25,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastMsgTime,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    unreadMsg == 0
                        ? Container()
                        : CircleAvatar(
                            radius: 12,
                            backgroundColor: CustomColor.unreadMsg,
                            child: Text(unreadMsg.toString()),
                          )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget ownStory(String img) {
    return Center(
      child: Stack(
        children: [
          storyWidget(img),
          Positioned(
              bottom: 3,
              right: 3,
              child: Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 15,
                  ),
                ),
              ))
        ],
      ),
    );
  }

  String showTime(DateTime time) {
    int timeHr = DateTime.now().difference(time).inDays;

    if (timeHr == 0) {
      return "${time.hour}:${time.minute.toString().padLeft(2, "0")}";
    } else if (timeHr == 1) {
      return "Yesterday";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}
