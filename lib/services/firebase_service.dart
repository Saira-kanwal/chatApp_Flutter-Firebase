import 'dart:io';
import 'package:chat_pp/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../Resources/utils.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService
{
  static final _auth = FirebaseAuth.instance;


  //...........User SignUp..................
  static void userSignUp({
    required BuildContext context,
    required String password,
    required String name,
    required String imageUrl,
    required String emailAddress,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      String uid = userCredential.user!.uid;
      postDetailsForGuest(
        name: name,
        email: emailAddress,
        imageUrl: imageUrl,
        uid: uid,
      );
      Utils.toastMessage("Successfully Registered, go to Login Screen");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Utils.toastMessage(
            'The password provided is too weak.');
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      }
      else if (e.code == 'email-already-in-use') {
        Utils.toastMessage(
            'The account already exists');
        if (kDebugMode) {
          print('The account already exists');
        }
      }
      else if (e.code == 'Document does not exist on the database') {
        Utils.toastMessage(
            "Document does not exist");
        if (kDebugMode) {
          print('Document does not exist');
        }
      }}
    catch (e) {
      Utils.toastMessage(e.toString());
    }
  }
  static postDetailsForGuest({
    required String email,
    required String name,
    required String imageUrl,
    required String uid,
  }) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(uid).set({
      'email': email,
      'name': name,
      'imageUrl': imageUrl,
      'id': uid,
    });
  }

  //.............SignIn......................
  static route({required Function() goToUser}) {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      goToUser();
        // if (documentSnapshot.get('role') == 'User'){
        //   goToUser();
        // } else {
        if (kDebugMode) {
          print('Document does not exist');
        // }
      }
    });
  }

  static signIn({
    required String email,
    required String password,
    required BuildContext context,
    required Function() goToUser}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      if(credential.user != null)
      {
        route(
            goToUser: () {
              goToUser();
            }
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.toastMessage('User not Found');
        if (kDebugMode) {
          print('No user found for that Email');
        }

      } else if (e.code == 'wrong-password') {
        Utils.toastMessage('Wrong Password');
        if (kDebugMode) {
          print('Wrong password provided for that user.');
        }
      }
    }catch (e) {
      Utils.toastMessage(e.toString());
      print(e);
    }

  }

  //...........Reset Password................
  static void resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
          Utils.toastMessage('Invalid email address');
        }
        else if (e.code == 'user-not-found') {
          Utils.toastMessage('User not Found');
        }


        if (kDebugMode) {
          print('Error sending password reset email: $e');
        }

      }
    }

  //.............Logout.......................
  static Future<void> logout({required Function() goToLogin,}) async {
    await _auth.signOut();
    goToLogin();
  }


  //............DataBase.....................
  static add({required String collection, required Map<String, dynamic>doc, required String docId})async
{
  // var user = _auth.currentUser;
  CollectionReference ref = FirebaseFirestore.instance.collection(collection);
  await ref.doc(docId).set({doc});

}

  static update({required Map<String, dynamic>doc,})async
  {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update(doc);
  }

  static delete({required String collection, required String docId})async
  {
    await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)  // Retrieve the document matching the current user's UID
        .get();
    return querySnapshot;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String uid) async {
    UserModel? userModel;
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)  // Retrieve the document matching the current user's UID
        .get();
    // if(querySnapshot.data() != null){
    //   userModel = UserModel.fromMap();
    // }
    return querySnapshot;
  }

  static Future<String?> uploadFile({required BuildContext context, required File file}) async
  {
    if(!file.existsSync())
    {
      return null;
    }
    String imageUrl = "" ;
    String fileName = path.basename(file.path);
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    // imageUrl = await reference.getDownloadURL();
    await reference.getDownloadURL().then((value) => imageUrl = value);
    return imageUrl;
  }

  static Future<List<QueryDocumentSnapshot>> getDocuments({required String collection, String? field1, String? field1Value}) async
  {
    List<QueryDocumentSnapshot> documents = [];
    if(field1 != null && field1Value != null)
    {
      var x = await FirebaseFirestore.instance.collection(collection).where(field1, isLessThanOrEqualTo: field1Value).where(field1, isGreaterThanOrEqualTo: field1Value).get();
      documents = x.docs;
    }
    else
    {
      var x = await FirebaseFirestore.instance.collection(collection).get();
      documents = x.docs;
    }


    return documents;
  }
}