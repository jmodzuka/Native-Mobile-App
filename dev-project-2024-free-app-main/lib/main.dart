// ignore_for_file: unused_import

import 'package:final_app/Screens/Authentication/login.dart';
import 'package:final_app/Screens/Authentication/password_screen.dart';
import 'package:final_app/Screens/Authentication/register_screen.dart';
import 'package:final_app/Screens/Authentication/screen_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


// Main function to initialize Firebase and run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());  // Use const for performance optimization
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Use super.key for the constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Disable the debug banner
      title: 'Free',  // App title
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Set a primary color theme
      ),
      home: const LoginScreen(),  // Set LoginScreen as the home screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const PasswordScreen(), 
        '/screen': (context) => const ScreenLogin(),
        '/register2': (context) => const RegisterScreen(),
      }, 
    );
  }
}
