import 'package:chatting_app/Model/chatModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/chatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key, required this.userData}) : super(key: key);
  final UserModel userData;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final uuid = const Uuid();
  TextEditingController searchController = TextEditingController();
  UserModel? searchedUser;
  ChatModel? openChat;

  Future<ChatModel?> openChatRoom() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${widget.userData.id}", isEqualTo: true)
        .where("participants.${searchedUser!.id}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      print("open room");
      ChatModel existingChatRoom = ChatModel.fromJson(snapshot.docs[0].data() as Map<String, dynamic>);
      openChat = existingChatRoom;
    } else {
      var chatroom = ChatModel(
          chatRoomId: widget.userData.id.toString()+searchedUser!.id.toString(),
          participants: [widget.userData.id.toString(), searchedUser!.id.toString()],
          lastMsg: "",
        lastMsgTime: null,
        online: {widget.userData.id.toString() : true, searchedUser!.id.toString() : false}
      );

      print("create room");
      await FirebaseFirestore.instance.collection("chatRooms").doc(chatroom.chatRoomId.toString()).set(chatroom.toMap());
      openChat = chatroom;
    }

    return openChat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Search Screen'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  setState(() {});
                },
                controller: searchController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  label: Text('Search'),
                  hintText: "Enter Email",
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text("Search")),
            const SizedBox(
              height: 30,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text)
                  .where("email", isNotEqualTo: widget.userData.email.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && searchController.text.isNotEmpty) {
                  print("snapshot got data ${snapshot.data!.docs.length}");
                  if (snapshot.data != null) {
                    QuerySnapshot data = snapshot.data!;
                    if (data.docs.isNotEmpty) {
                      var temp = data.docs[0].data() as Map<String, dynamic>;
                      searchedUser = UserModel.fromJson(temp);
                      if (searchedUser != null) {
                        return ListTile(
                          onTap: () async {
                            await openChatRoom().then((chatModelValue) {
                              if (chatModelValue != null) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatScreen(chatRoom: chatModelValue, currentUser: widget.userData, searchedUser: searchedUser!),
                                    ));
                              }
                            });
                          },
                          tileColor: Colors.black,
                          leading: const CircleAvatar(radius: 25, child: Icon(Icons.person)),
                          title: Text(
                            searchedUser!.name.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(searchedUser!.email.toString(), style: const TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        );
                      } else {
                        return const Text("Error Parsing Data");
                      }
                    } else {
                      return const Text("Enter valid Email");
                    }
                  } else {
                    return const Text("No Data Found!");
                  }
                } else if (snapshot.hasError) {
                  return const Text("An Error Occurred!");
                } else {
                  return const Text("Search For User!");
                }
              },
            )
          ],
        ),
      ),
    );
  }

  searchUser() {}
}
