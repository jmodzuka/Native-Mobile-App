import 'package:final_app/Screens/Settings/settingsscreen.dart';
import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

//Implementing defined Application primary colors
const Color primaryColor = Color.fromARGB(255, 50, 81, 239);
const Color primaryLightColor = Colors.blueAccent;
const Color primaryDarkColor = Colors.indigo;

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
      home: AccountDetailsPage(), 
      debugShowCheckedModeBanner: false,
    );
  }
}

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key}); //Key parameter for the widget

  @override
  AccountDetailsPageState createState() =>
      AccountDetailsPageState(); //Create the state for AccountDetailsPage
}

class AccountDetailsPageState extends State<AccountDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  //Get the authenticated user
  User? user = FirebaseAuth.instance.currentUser; 
  bool isLoading = true; 

  //Fields for user data
  String? firstName;
  String? lastName;
  String? password;
  String? confirmPassword;
  String? phoneNumber;
  String? email;
  String? backupEmail;

  @override
  void initState() {
    super.initState();
    fetchUserData(); //Fetch Firestore data
  }

  //Fetch user data from Firestore
  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser; //Get the current user
    if (user != null) {
      //Check if the user is authenticated
      String uid = user.uid; 
      DocumentSnapshot userDoc =
          await _firestore.collection('User').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?; //Check for null safety

        if (userData != null) {
          setState(() {
            firstName = userData['first_name'] as String?;
            lastName = userData['last_name'] as String?;
            password = userData['password'] as String?;
            email = userData['Email'] as String?;
            //Fetch phoneNumber as a number (int or double) and convert it to a string
            var phoneData = userData['cell_phone'];
            phoneNumber = phoneData?.toString();

            isLoading = false; //Data has loaded, stop showing loader
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, //Remove the shadow below the AppBar
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Edit profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) //Show loader until data is fetched
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Update your profile details.',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextFormField(
                          label: 'First Name',
                          initialValue: firstName ??
                              '', //Prepopulate field with Firestore data, default to empty if null
                          validatorMsg: 'This is a required Field',
                          onSaved: (value) => firstName = value!,
                        ),
                        const SizedBox(height: 16),
                        buildTextFormField(
                          label: 'Last Name',
                          initialValue:
                              lastName ?? '', //Prepopulate with Firestore data
                          validatorMsg: 'This is a required Field',
                          onSaved: (value) => lastName = value!,
                        ),
                        const SizedBox(height: 16),
                        buildTextFormField(
                          label: '10-digit SA Cell Number',
                          initialValue: phoneNumber ??
                              '', //Prepopulate with Firestore data
                          validatorMsg: 'This is a required Field',
                          onSaved: (value) => phoneNumber = value!,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.length != 10) {
                              return 'Phone number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20), 
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                
                                //Update firsetore with new details
                                await _firestore
                                    .collection('User')
                                    .doc(user!.uid)
                                    .update({
                                  'first_name': firstName,
                                  'last_name': lastName,
                                  'cell_phone': phoneNumber,
                                });

                                //Show success message 
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Profile updated successfully')),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SettingsScreen()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Update Details'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  TextFormField buildTextFormField({
    required String label,
    String? initialValue, //Initial value to pre-fill the form fields
    required String validatorMsg,
    required Function(String?) onSaved,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue, //Set initial value for text fields
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.edit),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return validatorMsg;
            }
            return null;
          },
      onSaved: (value) => onSaved(value),
    );
  }
}