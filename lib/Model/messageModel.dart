class MessageModel{
  String? msgId;
  String? msg;
  String? senderId;
  DateTime? createdOn;
  bool? seen;

  MessageModel({required this.msg, required this.msgId, required this.senderId, required this.createdOn, required this.seen});

  MessageModel.fromJson(Map<String, dynamic> data){
    msgId = data["msgId"];
    msg = data["msg"];
    senderId = data["senderId"];
    createdOn = data["createdOn"];
    seen = data["seen"];
  }

  Map<String, dynamic> toMap() => {
    "msgId" : msgId,
    "msg" : msg,
    "senderId" : senderId,
    "createdOn" : createdOn,
    "seen" : seen
  };
}