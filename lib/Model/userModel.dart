
class UserModel{
  String? id;
  String? name;
  String? email;
  String? profile;
  bool? isOnline;
  String? fcmToken;

  UserModel({required this.id, required this.name, required this.email, this.profile, this.isOnline, this.fcmToken});

  UserModel.fromJson(Map<String,dynamic> data){
    id = data["id"];
    email = data["email"];
    name = data["name"];
    profile = data["profile"];
    isOnline = data["isOnline"];
    fcmToken = data.containsKey("fcmToken") ? data["fcmToken"] : "";
  }

  Map<String,dynamic> toMap() => {
    'id' : id,
    'name' : name,
    'email' : email,
    'profile' : profile,
    'isOnline' : isOnline,
    'fcmToken' : fcmToken
  };
}