import 'package:chatting_app/Model/userModel.dart';
import 'package:chatting_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> login({required String email, required String pass}) async {
    UserModel? userData;

    try {
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email).then((value) async {
        if(value.isNotEmpty){
          if(value.contains("google.com")){
            showToast("This email is used for Google SignIn, Use another Email", Colors.deepOrangeAccent);
            return null;
          }else{
            /// [User exists with email/password]

            await _auth.signInWithEmailAndPassword(email: email, password: pass).then((user) async {
              String uid = user.user!.uid;

              DocumentSnapshot data = await FirebaseFirestore.instance.collection("users").doc(uid).get();
              var temp  = data.data() as Map<String,dynamic>;
              userData = UserModel.fromJson(temp);

              return userData;
            });
          }
        }else{
          /// [User does not exists]
          showToast("User does not exists, create new account", Colors.deepOrangeAccent);
          return null;
        }
      });
    } on FirebaseAuthException catch (e) {
      showToast("ERROR : ${e.message}", Colors.redAccent);
      return null;
    }

    return userData;
  }

  Future<UserModel?> signUp({required String name, required String email, required String pass}) async {
    UserModel? userData;

    try {
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email).then((value) async {
        if(value.isNotEmpty){
          if(value.contains("google.com")){
            showToast("This email is used for Google SignIn, Use another Email", Colors.deepOrangeAccent);
            return null;
          }else{
            showToast("Email already in use,try Login in your account", Colors.deepOrangeAccent);
            return null;
          }
        }else{
          /// [New user]
            await _auth.createUserWithEmailAndPassword(email: email, password: pass).then((user) async {

              String uid = user.user!.uid;
              UserModel newUser = UserModel(id: uid, email: email, name: name, isOnline: true, profile: "");
              await FirebaseFirestore.instance.collection("users").doc(uid).set(newUser.toMap()).then((value) {
                print('user created');
                userData = newUser;
              });
            });
        }
      });
    } on FirebaseAuthException catch (e) {
      showToast("ERROR : ${e.message}", Colors.redAccent);
      return null;
    }
    return userData;
  }

  Future<UserModel?> loginWithGoogle() async {
    print("google login");
    UserModel? user;
    try {
      GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
      if (googleAccount != null) {
        GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
        AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken
        );
        await FirebaseAuth.instance.signInWithCredential(authCredential).then((value) async {
          await FirebaseFirestore.instance.collection("users").doc(value.user!.uid).get().then((firebaseUser) async {
            await FirebaseFirestore.instance.collection("users").doc(value.user!.uid).update({"isOnline" : true}).then((value) {
              user = UserModel(id: firebaseUser["id"], name: firebaseUser["name"], email: firebaseUser["email"], isOnline: true);
            });
          });
        });
      }else{
        showToast("Some error with Google Id", Colors.redAccent);
      }
    } on FirebaseAuthException catch (e) {
      showToast("ERROR : ${e.message}", Colors.redAccent);
    }
    return user;
  }

  Future<UserModel?> signupWithGoogle() async{
    print("google signup");
    UserModel? user;
    try {
      GoogleSignInAccount? googleAccount = await GoogleSignIn().signIn();
      if (googleAccount != null) {
        GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
        AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken
        );
        await FirebaseAuth.instance.signInWithCredential(authCredential).then((value) async {
          UserModel newUser = UserModel(id: value.user!.uid, name: value.user!.displayName, email: value.user!.email, isOnline: true);

          await FirebaseFirestore.instance.collection("users").doc(value.user!.uid).set(newUser.toMap()).then((firebaseUser) {
            user = newUser;
          });
        });
      }else{
        showToast("Some error with Google Id", Colors.redAccent);
      }
    } on FirebaseAuthException catch (e) {
      showToast("ERROR : ${e.message}", Colors.redAccent);
    }
    return user;
  }

  Future<void> logOut() async {
    await _auth.signOut().then((value) async {
      bool isSignIn = await GoogleSignIn().isSignedIn();
      if(isSignIn){
        await GoogleSignIn().signOut().then((value) {
          showToast("success logout", Colors.deepOrangeAccent);
        });
      }else{
        showToast("success logout", Colors.deepOrangeAccent);
      }
    });
  }
}
