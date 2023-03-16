import 'package:cloud_firestore/cloud_firestore.dart';

class ChatGroupModel {
  String? chatRoomId;
  List? participants;
  String? lastMsg;
  Timestamp? lastMsgTime;
  Map<String, dynamic>? onlineParticipants;
  String? groupName;
  String? groupProfile;
  List? admins;
  String? groupDescription;
  List? unreadMsg;

  ChatGroupModel(
      {required this.chatRoomId,
      required this.participants,
      required this.lastMsg,
      required this.lastMsgTime,
      required this.onlineParticipants,
      required this.groupName,
      required this.groupProfile,
      required this.groupDescription,
      required this.admins,
      required this.unreadMsg});

  ChatGroupModel.fromJson(Map<String, dynamic> data) {
    chatRoomId = data["chatRoomId"];
    participants = data["participants"];
    lastMsg = data["lastMsg"];
    lastMsgTime = data["lastMsgTime"];
    onlineParticipants = data["onlineParticipants"];
    groupName = data["groupName"];
    groupProfile = data["groupProfile"];
    groupDescription = data["groupDescription"];
    admins = data["admins"];
    unreadMsg = data["unreadMsg"]  ;
  }

  Map<String, dynamic> toMap() => {
        "chatRoomId": chatRoomId,
        "participants": participants,
        "lastMsg": lastMsg,
        "lastMsgTime": lastMsgTime,
        "onlineParticipants": onlineParticipants,
        "groupName": groupName,
        "groupDescription": groupDescription,
        "groupProfile": groupProfile,
        "admins": admins,
        "unreadMsg": unreadMsg
      };
}


