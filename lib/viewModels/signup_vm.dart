import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class SignUpViewModel extends ChangeNotifier{
  GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool uploading = false;
  bool update = false;

  late final TextEditingController passwordController = TextEditingController();
  late final TextEditingController confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;
  set passwordVisible (bool val)
  {
    _passwordVisible = val;
    notifyListeners();
  }


  bool _confirmPasswordVisible = false;
  bool get confirmPasswordVisible => _confirmPasswordVisible;
  set confirmPasswordVisible (bool val)
  {
    _confirmPasswordVisible = val;
    notifyListeners();
  }

  bool _show = false;
  bool get show => _show;
  set show(bool val)
  {
    _show = val;
    notifyListeners();
  }

  File? _profileImage;
  String _profileImageUrl = "";
  File? get profileImage => _profileImage;
  String  get profileImageUrl => _profileImageUrl;
  set profileImage (File? val)
  {
    _profileImage = val;
    notifyListeners();
  }
  _uploadImage(BuildContext context) async{
    uploading = true;
    if(_profileImage != null)
    {
      _profileImageUrl = (await FirebaseService.uploadFile(context: context, file: _profileImage!))!;
    }
    Future.delayed(const Duration(seconds: 5));
    notifyListeners();
  }

  void signUp({required BuildContext context})async{

    if (signUpFormKey.currentState!.validate()){
      await  _uploadImage(context);
      FirebaseService.userSignUp(
          context: context,
          password: passwordController.text.trim().trim(),
          name: nameController.text.trim(),
          emailAddress: emailController.text.trim(),
          imageUrl:_profileImageUrl
      );
      emailController.clear();
      nameController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      _profileImageUrl = '';
      _profileImage = null;
      notifyListeners();
    }
  }

  UserModel? _currentUser ;
  UserModel? get  currentUser => _currentUser ;
  currentUserDetails() async
  {
    DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseService.getCurrentUser();
    _currentUser = UserModel.fromSnapshot(userSnapshot);
    notifyListeners();
    if (kDebugMode) {
      print(_currentUser?.name);
    }
  }
}
