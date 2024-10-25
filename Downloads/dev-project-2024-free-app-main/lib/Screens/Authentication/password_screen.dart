import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PasswordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});  // Key parameter added
  @override
  PasswordScreenState createState() => PasswordScreenState();  // Removed underscore
}
//adding this for github
class PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();  
  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool hasValidLength = false;
  bool isPasswordEmpty = true; 
  bool isSubmitted = false; 

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void validatePassword(String password) {
    setState(() {
      isPasswordEmpty = password.isEmpty;

      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasDigit = password.contains(RegExp(r'[0-9]'));
      hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~]'));
      hasValidLength = password.length >= 8 && password.length <= 20;
    });
  }

  // Function to register user with Firebase Authentication
  Future<void> _registerUser(String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'test@example.com', 
        password: password,
      );
      print('User registered: ${userCredential.user?.email}');
      // Navigate to next screen if successful
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print('Error registering user: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              "REGISTER",
              style: TextStyle(
                fontSize: 18,  
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color.fromARGB(255, 0, 0, 0)), 
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),  
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create a Password:', 
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),  
            const Text(
              'This will be used as your login credentials for the app.',  
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            const SizedBox(height: 20),  
            TextField(
              controller: _passwordController,
              onChanged: validatePassword,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your password',
              ),
            ),
            const SizedBox(height: 10), 
            Text(
              'This is a required field.',  
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: (isPasswordEmpty && isSubmitted) ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 10),  
            _buildPasswordRequirement("Between 8 and 20 characters", hasValidLength),
            _buildPasswordRequirement("At least 1 lowercase character", hasLowercase),
            _buildPasswordRequirement("At least 1 uppercase character", hasUppercase),
            _buildPasswordRequirement("At least 1 digit", hasDigit),
            _buildPasswordRequirement("At least 1 special character", hasSpecialChar),
            const SizedBox(height: 20), 
            Center(  
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isSubmitted = true; // Mark as submitted when the button is pressed
                  });

                  // Proceed to next screen if the password is valid
                  if (!isPasswordEmpty && hasValidLength && hasLowercase && hasUppercase && hasDigit && hasSpecialChar) {
                    _registerUser(_passwordController.text);  
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildPasswordRequirement(String requirement, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            Icons.check, // Changed to use a simple checkmark
            color: isValid ? Colors.green : Colors.grey, 
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            requirement,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
