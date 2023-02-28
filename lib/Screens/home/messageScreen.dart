import 'package:chatting_app/Model/chatModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key, required this.userData}) : super(key: key);
  final UserModel userData;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isBg = state == AppLifecycleState.paused;
    final isScreen = state == AppLifecycleState.resumed;
    final isClosed = state == AppLifecycleState.detached;

    isScreen == true
        ? setState(() {
            FirebaseFirestore.instance.collection("users").doc(widget.userData.id).update({"isOnline": true});
          })
        : setState(() {
            FirebaseFirestore.instance.collection("users").doc(widget.userData.id).update({"isOnline": false});
          });

    // super.didChangeAppLifecycleState(state);
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
          child: Container(
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
                // print(snapshot.data!.docs.toList());
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return recentChatWidget(snapshot.data!.docs[index].data());
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Error Fetching Data", style: TextStyle(fontSize: 18)));
                  } else {
                    return const Center(child: Text("Start Chatting With Friends", style: TextStyle(fontSize: 18)));
                  }
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

  Widget recentChatWidget(Map<String, dynamic> data) {
    String? otherUser;
    ChatModel chatData = ChatModel.fromJson(data);
    for (var element in chatData.participants!) {
      if (element.toString() != widget.userData.id.toString()) {
        otherUser = element;
        // print("other user = " + otherUser);
      }
    }
    // print(data.toString());
    return otherUser != null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").doc(otherUser).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                UserModel searchedUser = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                print("user data" + searchedUser.toMap().toString());
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(chatRoom: chatData, currentUser: widget.userData, searchedUser: searchedUser),
                        ));
                  },
                  child: Container(
                    // color:Colors.blueAccent,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 70,
                    // decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(100)
                    // ),
                    // color: Colors.grey,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          Stack(children: [
                            const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/dp3.png'),
                              radius: 26,
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
                                        ? (searchedUser.isOnline! ? const Color(0xFF0FE16D) : Colors.grey)
                                        : Colors.red),
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
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  chatData.lastMsg.toString(),
                                  style: const TextStyle(fontSize: 12),
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
                              children: const [
                                Text(
                                  '5 min ago',
                                  style: TextStyle(fontSize: 12),
                                ),
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Color(0xFFF04A4C),
                                  child: Text('5'),
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
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
        : const Center(child: CircularProgressIndicator());
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
}
