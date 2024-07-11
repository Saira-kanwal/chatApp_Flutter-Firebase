import 'package:chat_pp/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import '../Helper/keyboard.dart';
import '../screens/user_list/userlist_screen.dart';
import '../services/firebase_service.dart';
class LoginViewModel extends ChangeNotifier{

  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _show = false;


  bool get show => _show;
  bool get passwordVisible => _passwordVisible;


  set passwordVisible (bool val)
  {
    _passwordVisible = val;
    notifyListeners();
  }
  set show(bool val)
  {
    _show = val;
    notifyListeners();
  }

  // set loading(bool val)
  // {
  //     _loading = val;
  //     notifyListeners();
  // }

  void logIn(BuildContext context) async{
    _show = true;
    if(loginFormKey.currentState!.validate())
    {
      await FirebaseService.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          context: context,
          goToUser: () async {
            KeyboardUtil.hideKeyboard(context);
            await Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
          }
      );
      emailController.clear();
      passwordController.clear();
      notifyListeners();
    }
    _show = false;
  }
}