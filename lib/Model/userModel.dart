
class UserModel{
  String? id;
  String? name;
  String? email;
  String? profile;

  UserModel({required this.id, required this.name, required this.email, this.profile});

  UserModel.fromJson(Map<String,dynamic> data){
    id = data["id"];
    email = data["email"];
    name = data["name"];
    profile = data["profile"];
  }

  Map<String,dynamic> toMap() => {
    'id' : id,
    'name' : name,
    'email' : email,
    'profile' : profile
  };
}