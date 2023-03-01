import 'package:chatting_app/Model/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> login({required String email, required String pass}) async {
    UserCredential? user;
    UserModel? userData;

    try {
      user = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      print('here data ${user.user!.uid.toString()}  ${user.user!.email}');
    } on FirebaseAuthException catch (e) {
      print('error ${e.code}');
    }
    
    if(user != null){
      String uid = user.user!.uid;
      
      DocumentSnapshot data = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      var temp  = data.data() as Map<String,dynamic>;
      userData = UserModel.fromJson(temp);
    }

    return userData;
  }

  Future<UserModel?> signUp({required String name, required String email, required String pass}) async {
    UserCredential? user;
    UserModel? userData;

    try {
      print("in function");
      user = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (e) {
      print('error ${e.message.toString()}');
    }

    if (user != null) {
      String uid = user.user!.uid;
      UserModel newUser = UserModel(id: uid, email: email, name: name, isOnline: false, profile: "");
      await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value) {
        print('user created');
        userData = newUser;
      });
      return userData!;
    }else{
      return null;
    }
  }

  Future<void> logOut() async {
    await _auth.signOut().then((value) {
      print("success logout");
    });
  }
}
