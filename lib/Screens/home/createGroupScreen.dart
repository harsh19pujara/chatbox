import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/Screens/home/groupDetailsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key, required this.userData}) : super(key: key);
  final UserModel userData;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<UserModel> participants = [];
  final TextEditingController _memberController = TextEditingController();
  UserModel? searchedUser;

  @override
  void initState() {
    participants.add(widget.userData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue,
        title: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {});
            },
            cursorColor: Colors.white,
            controller: _memberController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(

              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.white),
              label: Text('Search'),
              hintText: "Enter Email",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        // centerTitle: true,
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Add Members",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                  )),
              LimitedBox(
                maxHeight: MediaQuery.of(context).size.height / 3 - 30,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  // height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)),
                  child: ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          title: Text(participants[index].name.toString()),
                          subtitle: Text(participants[index].email.toString()),
                          trailing: IconButton(
                              onPressed: () {
                                if (participants[index] != widget.userData) {
                                  participants.removeAt(index);
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
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("email", isGreaterThanOrEqualTo: _memberController.text)
                    .where("email", isLessThanOrEqualTo: "${_memberController.text}~")
                    .where("email", isNotEqualTo: widget.userData.email.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && _memberController.text.isNotEmpty) {
                    if (snapshot.data != null) {
                      QuerySnapshot data = snapshot.data!;
                      if (data.docs.isNotEmpty) {
                        List<UserModel> searchedUserList = data.docs.map((e) {
                          return UserModel.fromJson(e.data() as Map<String, dynamic>);
                        }).toList();

                        return LimitedBox(
                          maxHeight: MediaQuery.of(context).size.height / 3 + 100,
                          child: ListView.builder(
                            itemCount: searchedUserList.length,
                            itemBuilder: (context, index) {
                              // searchedUser = searchedUserList[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                color: Colors.blueGrey,
                                child: ListTile(
                                  onTap: () {
                                    bool temp = true;
                                    for (var e in participants) {
                                      if (e.email == searchedUserList[index].email) {
                                        temp = false;
                                      }
                                    }
                                    if (temp) {
                                      participants.add(searchedUserList[index]);
                                      setState(() {
                                        // _memberController.clear();
                                      });
                                    }
                                  },
                                  // tileColor: Colors.black,
                                  leading: const CircleAvatar(backgroundColor: Colors.grey,radius: 25, child: Icon(Icons.person)),
                                  title: Text(
                                    searchedUserList[index].name.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle:
                                      Text(searchedUserList[index].email.toString(), style: const TextStyle(color: Colors.white)),
                                ),
                              );
                            },
                          ),
                        );
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
      ),
      floatingActionButton: participants.length >= 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetails(participants: participants, userData: widget.userData),
                    ));
              },
              child: const Icon(
                Icons.arrow_forward,
                size: 28,
              ))
          : null,
    );
  }
}
