import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List contacts = [];
  @override
  void initState() async{
    getContactsData();
    super.initState();
  }

  getContactsData() async{
    contacts = await ContactsService.getContacts();
    setState(() {});
    print("got data" + contacts.toString());

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: contacts.isNotEmpty ? ListView.builder(itemCount: contacts.length,itemBuilder: (context, index) {
        return Container(color: Colors.blueAccent,);
      },) : const Center(child: CircularProgressIndicator(),),

    );
  }
}

