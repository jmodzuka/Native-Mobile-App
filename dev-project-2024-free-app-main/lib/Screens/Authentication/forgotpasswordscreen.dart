
import 'package:final_app/Screens/Authentication/login.dart';
import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/firebase_auth.dart';  


//Implementing defined Application primary colors
const Color primaryColor = Color.fromARGB(255, 50, 81, 239);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ForgotPasswordScreen(),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  //Function to handle password reset
  Future<void> _resetPassword(BuildContext context) async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      //Show error if email is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    try {
      //Send a password reset email via Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );

       //Navigate to the PasswordRecoveryScreen 
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EnterEmail()),
      );
    } catch (e) {
      //Display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); //Go back to the previous screen
          },
        ),
        title: const Text(
            'FORGOT PASSWORD',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
      ),
      body: Container(
        color: Colors.white, 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email:',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will receive an email with a reset code to log into your account.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Email',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _emailController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 32), 
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _resetPassword(context); //Trigger password reset function
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, 
                  minimumSize: const Size(150, 45), //Set custom button size (width, height)
                ),
                child: const Text(
                  'Send Email',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
