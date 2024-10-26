import 'package:final_app/Screens/Authentication/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScreenLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScreenLogin extends StatefulWidget {
  const ScreenLogin({super.key});

  @override
  ScreenLoginState createState() => ScreenLoginState();
}

class ScreenLoginState extends State<ScreenLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); 
  bool isValidEmail = false;
  String emailMessage = '';
  bool isEmailEmpty = true;
  bool isPasswordEmpty = true; 
  bool isSubmitted = false; 
  bool hasLowercase = false;
  bool hasUppercase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool hasValidLength = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose(); // Dispose of the password controller
    super.dispose();
  }

  void validateEmail(String email) {
    setState(() {
      isEmailEmpty = email.isEmpty;

      if (!isEmailEmpty) {
        // Basic email validation using regex
        isValidEmail = RegExp(
          r'^[^@]+@[^@]+\.[^@]+', // Basic email validation pattern
        ).hasMatch(email);

        // Update the message based on the email's validity
        emailMessage = isValidEmail
            ? "This is a valid email address"
            : "Sorry, this is not a valid email address";
      } else {
        emailMessage = ""; // Clear the message if the field is empty
      }
    });
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
  Future<void> _registerUser(String email, String password) async {
    try {
      // Check if the email is already in use
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

    
      print('User registered: ${userCredential.user?.email}');
      // Navigate to the next screen if successful
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('Error: The account already exists for that email.');
        // Show error message in a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The account already exists for that email.')),
        );
      } else {
        print('Error registering user: ${e.message}');
        // You can display an error message here if needed
      }
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
            fontSize: 18,
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
            const SizedBox(height: 20), // Ensures consistent spacing between sections
            const Text(
              'Enter your email:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Adjust spacing after the label
            TextField(
              controller: _emailController,
              onChanged: validateEmail,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 20), // Consistent spacing before the next section

            if (!isEmailEmpty && emailMessage.isNotEmpty)
              Text(
                emailMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: isValidEmail ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 20), // Consistent spacing before the password section

            const Text(
              'Enter your password:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Adjust spacing after the label
            TextField(
              controller: _passwordController,
              obscureText: true, // Hides the password input
              onChanged: (password) {
                validatePassword(password);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your password',
              ),
            ),
            const SizedBox(height: 20), // Consistent spacing after the password input

            // Password requirements
            _buildPasswordRequirement("Between 8 and 20 characters", hasValidLength),
            _buildPasswordRequirement("At least 1 lowercase character", hasLowercase),
            _buildPasswordRequirement("At least 1 uppercase character", hasUppercase),
            _buildPasswordRequirement("At least 1 digit", hasDigit),
            _buildPasswordRequirement("At least 1 special character", hasSpecialChar),

            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isSubmitted = true; // Mark as submitted when the button is pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterScreen()), 
                          );
                        
                      });

                      // Proceed to registration only if the email and password are valid
                      if (!isEmailEmpty && isValidEmail && !isPasswordEmpty && hasValidLength && hasLowercase && hasUppercase && hasDigit && hasSpecialChar) {
                        _registerUser(_emailController.text, _passwordController.text); 
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Next'),
                  ),
                ],
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
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            requirement,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: isValid ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
