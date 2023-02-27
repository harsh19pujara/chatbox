
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel{
   String? chatRoomId;
   List? participants;
   String? lastMsg;
   Timestamp? lastMsgTime;


  ChatModel({required this.chatRoomId,required this.participants,required this.lastMsg, required this.lastMsgTime});

  ChatModel.fromJson(Map<String,dynamic> data){
    chatRoomId  = data["chatRoomId"];
    participants = data["participants"];
    lastMsg = data["lastMsg"];
    lastMsgTime = data["lastMsgTime"] ;
  }

  Map<String,dynamic> toMap() =>{
    "chatRoomId" : chatRoomId,
    "participants" : participants,
    "lastMsg" : lastMsg,
    "lastMsgTime" : lastMsgTime
  };
}