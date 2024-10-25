import 'package:final_app/Screens/Authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RegisterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cellPhoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String cellPhone =_cellPhoneController.text; 

    if (firstName.isNotEmpty && lastName.isNotEmpty && cellPhone.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user

      if (user != null) {
        // Ensure the user is authenticated
        String uid = user.uid; 
        await FirebaseFirestore.instance.collection('User').doc(uid).set(
          {
            'registrationDate': DateTime.now(), 
            'first_name': firstName,
            'last_name': lastName,
            'cell_phone': cellPhone,
          },
        );

        print("User data updated in Firestore.");

        // **Navigate only after successful update**
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        print(
            "No authenticated user found."); // Log if no user is authenticated
      }
    } else {
      print("Please fill out all fields."); // Handle validation errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "REGISTER",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please complete your details to finish your registration.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'First Name',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is a required field.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Last Name',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is a required field.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cellPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '10-digit SA Cell Phone Number',
              ),
               inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Restrict to digits only
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'This is a required field.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _registerUser();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
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
}