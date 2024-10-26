import 'package:final_app/Screens/Authentication/forgotpasswordscreen.dart';
import 'package:final_app/Screens/Home/landingscreen.dart';
import 'package:final_app/Screens/Authentication/screen_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EnterEmail(); // Main screen is now the email screen
  }
}

class EnterEmail extends StatefulWidget {
  const EnterEmail({super.key});

  @override
  EnterEmailState createState() => EnterEmailState();
}

class EnterEmailState extends State<EnterEmail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorText; // To hold error message if the email is invalid

  // Function to validate email format using regex
  bool _validateEmail(String email) {
    const String emailPattern =
        r'^[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$';
    final RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  // Sign-in action: validate email and use Firebase Authentication
  void _signIn(BuildContext context) async {
    if (_validateEmail(_emailController.text)) {
      setState(() {
        _errorText = null; // Valid email
      });

      try {
        // Sign in with Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Successfully signed in
        print("User signed in: ${userCredential.user?.email}");

        // Check if widget is still mounted before navigating
        if (!mounted) return;

        // Navigate to the landing page after successful sign-in
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LandingScreen(events: {},)), 
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorText = e.message; // Show error message if sign-in fails
        });
      }
    } else {
      setState(() {
        _errorText =
            'Invalid email address'; // Show error message if email is invalid
      });
    }
  }

  // Modified function to handle Google Sign-In
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Initialize GoogleSignIn with default configuration for the platform
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      // Sign out any previous user
      await FirebaseAuth.instance.signOut();  
      await googleSignIn.signOut();           

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in process
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In was canceled.')),
        );
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credentials
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${user?.displayName}')),
      );

      // Navigate to the landing page after successful sign-in
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LandingScreen(events: {},)), 
      );

      return user;
    } catch (e) {
      // Log the error for debugging purposes
      print('Google Sign-In error: $e');

      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo.jpg', 
                  height: 250, 
                ),
                const SizedBox(height: 0),

                // Email Input Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    border: const OutlineInputBorder(),
                    errorText: _errorText, // Display error if any
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Enter your password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In Button (longer width)
                SizedBox(
                  width: double.infinity, // Make the button full width
                  child: ElevatedButton(
                    onPressed: () => _signIn(context), // Pass context to _signIn
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue, 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), 
                      ),
                    ),
                    child: const Text('SIGN IN'),
                  ),
                ),
                const SizedBox(height: 20),

                // OR Divider
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign in with Google Button (equal width)
                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await signInWithGoogle(context);
                    },
                    icon: Image.asset(
                      'assets/gmail.png', 
                      width: 24,
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, 
                      foregroundColor:
                          Colors.black, 
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        side:
                            BorderSide(color: Colors.grey[400]!), 
                        borderRadius:
                            BorderRadius.circular(30), 
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register & Forgot Password Options (rounded edges and grey background)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Register Button (grey background, black text, rounded edges)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to the RegisterScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ScreenLogin()), 
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Colors.grey[300],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), 
                          ),
                        ),
                        child: const Text(
                          'REGISTER',
                          style: TextStyle(
                              color: Colors.black), 
                        ),
                      ),
                    ),

                    const SizedBox(width: 10), 

                    // Forgot Password Button 
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Colors.grey[300], 
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), 
                          ),
                        ),
                        child: const Text(
                          'FORGOT PASSWORD',
                          style: TextStyle(
                              color: Colors.black), 
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
