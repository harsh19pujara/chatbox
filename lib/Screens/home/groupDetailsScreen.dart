import 'package:chatting_app/Model/chatGroupModel.dart';
import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/groupChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupDetails extends StatefulWidget {
  const GroupDetails({Key? key, required this.participants, required this.userData}) : super(key: key);
  final List<UserModel> participants;
  final UserModel userData;

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  TextEditingController groupNameController = TextEditingController();
  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Group Details"),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {},
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.group,
                      size: 40,
                      color: Colors.white,
                    ),
                  )),
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: groupNameController,
                  decoration: const InputDecoration(
                    hintText: "Group Name",
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              LimitedBox(
                maxHeight: MediaQuery.of(context).size.height / 2 - 40,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  // height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)),
                  child: ListView.builder(
                    itemCount: widget.participants.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          title: Text(widget.participants[index].name.toString()),
                          subtitle: Text(widget.participants[index].email.toString()),
                          trailing: IconButton(
                              onPressed: () {
                                if (widget.participants[index] != widget.userData) {
                                  widget.participants.removeAt(index);
                                  setState(() {});
                                }
                              },
                              icon: const Icon(Icons.cancel_outlined)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async{
          Map<String, dynamic> temp = {};
          List<String> idList = [];
          List<Map<String, dynamic>> unreadMsgList = [];

          for(var e in widget.participants){
            temp[e.id.toString()] = false;
            idList.add(e.id.toString());
            unreadMsgList.add({e.id.toString() : 0});
          }

          print("map" + temp.toString());
          print("list" + idList.toString());
          final ChatGroupModel data = ChatGroupModel(
              chatRoomId: uuid.v1(),
              participants: idList,
              lastMsg: "",
              lastMsgTime: Timestamp.now(),
              onlineParticipants: temp,
              groupName: groupNameController.text,
              groupProfile: "",
              groupDescription: "",
              admins: [widget.userData.id.toString()],
            unreadMsg: unreadMsgList
          );

          try {
            await FirebaseFirestore.instance.collection("chatGroups").doc(data.chatRoomId.toString()).set(data.toMap()).then((value) {
              print("group created");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GroupChat(chatGroup: data, currentUser: widget.userData),));
            });
          } on Exception catch (e) {
            throw e.toString();
          }
        },
        child: Container(
          height: 60,
          width: 120,
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(30)),
          child: const Center(
              child: Text(
            "Create Group",
            style: TextStyle(color: Colors.white, fontSize: 17),
          )),
        ),
      ),
    );
  }
}
