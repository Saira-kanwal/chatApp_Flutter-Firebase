import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ResetViewModel extends ChangeNotifier{

  GlobalKey<FormState> resetFormKey = GlobalKey<FormState>();
  final TextEditingController restEmailController = TextEditingController();


  void resetPassword(BuildContext context)async {
    FirebaseService.resetPassword(restEmailController.text.toString());
  }

}