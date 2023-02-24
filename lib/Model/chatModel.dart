
class ChatModel{
   String? chatRoomId;
   Map<String,dynamic>? participants;
   String? lastMsg;

  ChatModel({required this.chatRoomId,required this.participants,required this.lastMsg});

  ChatModel.fromJson(Map<String,dynamic> data){
    chatRoomId  = data["chatRoomId"];
    participants = data["participants"];
    lastMsg = data["lastMsg"];
  }

  Map<String,dynamic> toMap() =>{
    "chatRoomId" : chatRoomId,
    "participants" : participants,
    "lastMsg" : lastMsg
  };
}