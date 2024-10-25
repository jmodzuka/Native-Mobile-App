import 'package:final_app/Screens/Home/landingscreen.dart';
import 'package:final_app/Screens/Settings/settingsscreen.dart';
import 'package:flutter/material.dart'; 
import 'package:google_sign_in/google_sign_in.dart'; 
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  

//Implementing defined Application primary color
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
      home: ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/contacts.readonly'], //Implementing google APIs
  );
  int _selectedIndex = 1; //Setting the selected icon and page on the navigation bare
  bool _loading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Map<String, String>> _contacts = []; // List storing all contacts (e.g., name, phone number)
  List<Map<String, String>> _filteredContacts = []; // List storing contacts filtered by search criteria, initially empty
  final TextEditingController _searchController = TextEditingController(); // Controller handling the input from the search text field (captures and manages search queries)

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _loading = true; //loading contacts from google account
    });

    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user != null) {
        final auth = await user.authentication;
        final googleContacts = await fetchGoogleContacts(auth.accessToken!);

        print("Google Contacts: $googleContacts");  

        final registeredContacts = await filterRegisteredContacts(googleContacts);

        print("Registered Contacts: $registeredContacts"); 

        setState(() {
          _contacts = registeredContacts;
          _filteredContacts = registeredContacts;
        });
      }
    } catch (error) {
      print('Error fetching contacts: $error');
    }

    setState(() {
      _loading = false;
    });
  }

  Future<List<Map<String, String>>> fetchGoogleContacts(String token) async { 
    //Line below gets the Google People API to retrieve contact, with specified fields: names, phone numbers, and photos.
    final response = await http.get( 
      Uri.parse(
        'https://people.googleapis.com/v1/people/me/connections?personFields=names,phoneNumbers,photos',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, String>> contacts = [];

      for (var person in data['connections']) {
        final name = person['names']?.first['displayName'];
        final phoneNumber = person['phoneNumbers']?.first['value'];
        final photoUrl = person['photos']?.first['url'];

        if (name != null && phoneNumber != null) {
          contacts.add({
            'name': name,
            'phoneNumber': _normalizePhoneNumber(phoneNumber), 
            'photoUrl': photoUrl ?? '',
          });
        }
      }
      return contacts;
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<List<Map<String, String>>> filterRegisteredContacts(
      List<Map<String, String>> googleContacts) async {
    final firestore = FirebaseFirestore.instance;
    final registeredUsersSnapshot = await firestore.collection('User').get();  //Updated collection name

    List<Map<String, String>> registeredContacts = [];

    for (var doc in registeredUsersSnapshot.docs) {
      final firestorePhoneNumber = _normalizePhoneNumber(doc['cell_phone']);  //Normalising phone number 

      for (var contact in googleContacts) {
        if (firestorePhoneNumber == contact['phoneNumber']) {
          //If phone number matches, add to the registered contacts list
          registeredContacts.add({
            'name': contact['name']!,
            'phoneNumber': contact['phoneNumber']!,
            'photoUrl': contact['photoUrl']!,
          });
        }
      }
    }

    return registeredContacts;
  }

  //Normalising phone numbers to compare correctly
  String _normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');  //Remove all non-numeric characters
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        final name = contact['name']!.toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.jpg', 
          height: 100.0,
        ),
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white, 
        elevation: 0, 
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 60.0,
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactListScreen()),
                    );
                    _onItemTapped(1);
                  },
                  color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LandingScreen(events: {},)),
                    );
                    _onItemTapped(2);
                  },
                  color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                    _onItemTapped(4);
                  },
                  color: _selectedIndex == 4 ? Colors.black : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                'Connections',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for connection',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'From your contacts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                    ? const Center(child: Text('No registered contacts found'))
                    : ListView.builder(
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(255, 48, 17, 133),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: _filteredContacts[index]['photoUrl']!.isNotEmpty
                                      ? NetworkImage(_filteredContacts[index]['photoUrl']!)
                                      : null,
                                  backgroundColor: primaryColor, //Set background color 
                                  child: _filteredContacts[index]['photoUrl']!.isEmpty
                                      ? Text(
                                          _filteredContacts[index]['name']![0],
                                          style: const TextStyle(color: Colors.white),
                                        )
                                      : null,
                                ),
                                title: Text(_filteredContacts[index]['name']!),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}


Future<void> registerUser(String firstName, String lastName, String phoneNumber) async {
  String formattedPhoneNumber = phoneNumber.trim();

  //Add user to Firestore under the 'User' collection
  await FirebaseFirestore.instance.collection('User').add({
    'first_name': firstName,
    'last_name': lastName,
    'cell_phone': formattedPhoneNumber,  
  });

  print('User registered successfully with phone number: $formattedPhoneNumber'); 
}

//Function to update stored phone numbers in Firestore
Future<void> updateIncorrectPhoneNumbers() async {
  final usersSnapshot = await FirebaseFirestore.instance.collection('User').get();

  for (var doc in usersSnapshot.docs) {
    String phoneNumber = doc['cell_phone'];

    //Check if the phone number needs correction (for example, it's missing a leading zero)
    if (phoneNumber.length == 9 && !phoneNumber.startsWith('0')) {
      // Add leading zero back to the phone number
      String correctedPhoneNumber = '0' + phoneNumber;

      //Update the cell_phone field in Firestore with the corrected phone number
      await FirebaseFirestore.instance.collection('User').doc(doc.id).update({
        'cell_phone': correctedPhoneNumber
      });

      print('Updated phone number for user ${doc.id}');
    }
  }
}
