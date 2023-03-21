import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> contacts = [];
  String currentContact = '';
  String prevContact = '';

  @override
  void initState() {
    getPermission();
    super.initState();
  }

  getPermission() async {
    if (await Permission.contacts.isGranted) {
      contacts = await ContactsService.getContacts();
      if (contacts.isNotEmpty) {
        setState(() {});
      }
    } else {
      await Permission.contacts.request().then((value) async{
        contacts = await ContactsService.getContacts();
      }).then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.only(top: 30,bottom: 0, right: 20,left: 20),
        decoration: const BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40))),
        child : Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("My Contacts", style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
            const SizedBox(height: 15,),
            Expanded(child: contacts.isNotEmpty
                ? ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return contactTile(index);
              },
            )
                : const Center(
              child: CircularProgressIndicator(),
            ),)
        ])
      ),
    );
  }

  Widget contactTile(int index){
    var contactNum = contacts[index].phones![0].value;
    String letter = contacts[index].displayName![0].trim();
    bool showLetter = true;

    if (index > 0) {
      if(contacts[index].displayName![0].trim() == contacts[index-1].displayName![0].trim()){
        showLetter = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showLetter ? Text(letter.toUpperCase(),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),) : Container(),
        showLetter ? const SizedBox(height: 5,) : Container(),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          leading: const CircleAvatar(backgroundColor: Color(0xFFa8e5f0),child: Icon(Icons.person),),
          title: Text(contacts[index].displayName.toString()),
          subtitle: Text(contactNum.toString()),
        ),
      ],
    );
  }
}
