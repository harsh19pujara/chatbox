
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel{
   String? chatRoomId;
   List? participants;
   String? lastMsg;
   Timestamp? lastMsgTime;
   Map<String,dynamic>? online;

  ChatModel({required this.chatRoomId,required this.participants,required this.lastMsg, required this.lastMsgTime, required this.online});

  ChatModel.fromJson(Map<String,dynamic> data){
    chatRoomId  = data["chatRoomId"];
    participants = data["participants"];
    lastMsg = data["lastMsg"];
    lastMsgTime = data["lastMsgTime"] ;
    online = data["online"];
  }

  Map<String,dynamic> toMap() =>{
    "chatRoomId" : chatRoomId,
    "participants" : participants,
    "lastMsg" : lastMsg,
    "lastMsgTime" : lastMsgTime,
    "online" : online
  };
}