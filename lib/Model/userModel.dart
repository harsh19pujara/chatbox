
class UserModel{
  String? id;
  String? name;
  String? email;
  String? profile;
  bool? isOnline;

  UserModel({required this.id, required this.name, required this.email, this.profile, this.isOnline});

  UserModel.fromJson(Map<String,dynamic> data){
    id = data["id"];
    email = data["email"];
    name = data["name"];
    profile = data["profile"];
    isOnline = data["isOnline"];
  }

  Map<String,dynamic> toMap() => {
    'id' : id,
    'name' : name,
    'email' : email,
    'profile' : profile,
    'isOnline' : isOnline
  };
}