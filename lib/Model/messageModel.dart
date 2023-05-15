import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? msgId;
  String? msg;
  String? senderId;
  Timestamp? createdOn;
  bool? seen;
  String? msgType;
  String? thumbnail;
  String? repliedTo;
  bool? isEncrypted;

  MessageModel({required this.msgType, required this.msg, required this.msgId, required this.senderId, required this.createdOn, required this.seen, this.thumbnail, this.repliedTo, this.isEncrypted});

  MessageModel.fromJson(Map<String, dynamic> data){
    msgId = data["msgId"];
    msg = data["msg"];
    senderId = data["senderId"];
    createdOn = data["createdOn"];
    seen = data["seen"];
    msgType = data["msgType"];
    thumbnail = data["thumbnail"];
    repliedTo = data["repliedTo"];
    isEncrypted = data["isEncrypted"];
  }

  Map<String, dynamic> toMap() => {
    "msgId" : msgId,
    "msg" : msg,
    "senderId" : senderId,
    "createdOn" : createdOn,
    "seen" : seen,
    "msgType" : msgType,
    "thumbnail" : thumbnail,
    "repliedTo" : repliedTo,
    "isEncrypted" : isEncrypted
  };
}