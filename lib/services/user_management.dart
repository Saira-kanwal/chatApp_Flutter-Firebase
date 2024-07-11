import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserManagement with ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;


  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}