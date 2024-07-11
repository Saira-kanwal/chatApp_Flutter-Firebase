
import 'package:chat_pp/services/user_management.dart';
import 'package:chat_pp/viewModels/chat_vm.dart';
import 'package:chat_pp/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'viewModels/login_vm.dart';
import 'viewModels/reset_password_vm.dart';
import 'viewModels/signup_vm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider (create: (_) => UserManagement()),
          ChangeNotifierProvider (create: (_) => ChatViewModel()),
          ChangeNotifierProvider (create: (_) => LoginViewModel()),
          ChangeNotifierProvider (create: (_) => ResetViewModel()),
          ChangeNotifierProvider (create: (_) => SignUpViewModel()),
        ],
        child:
        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          theme: AppTheme.lightTheme(context),
          home: const AuthenticationWrapper(),
        )
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagement>(
        builder: (context, authProvider, child){
          if(authProvider.isSignedIn){
            print(authProvider.isSignedIn);
            return const HomeScreen();
          }
          else{
            print('Splash');
            return const SplashScreen();
          }
        }
    );
  }
}



