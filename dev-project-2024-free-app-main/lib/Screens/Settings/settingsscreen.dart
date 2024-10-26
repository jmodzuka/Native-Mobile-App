import 'package:final_app/Screens/Authentication/login.dart'; 
import 'package:final_app/Screens/Settings/adding_calendars.dart';
import 'package:flutter/material.dart'; 
import 'package:final_app/Screens/Home/landingscreen.dart';
import 'package:final_app/Screens/Settings/account_details.dart';
import 'package:final_app/Screens/Home/invite_external_connections.dart';

// Defining application primary colors
const Color primaryColor = Color.fromARGB(255, 50, 81, 239);
const Color primaryLightColor = Colors.blueAccent;
const Color primaryDarkColor = Colors.indigo;


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

//Initialising settings screen state
class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 4;

//Initialising the bottom navigation bar selected index for settings screen
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isPrivateMode = false; //Implementing private mode feature, where current user will not be visible to other users when bool is true 

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
        elevation: 0, // This line removes the shadow below the AppBar
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 60.0, //Defining the height of the navigation bar
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    //Navigating to the COntacts screen once the person icon is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ContactListScreen()),
                    );
                    _onItemTapped(1);
                  },
                  color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    //Navigating to the Landing screen once the home icon is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LandingScreen(events: {},)),
                    );
                    _onItemTapped(2);
                  },
                  color: _selectedIndex == 2 ? Colors.black : Colors.grey,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    //Navigating to the Settings screen once the settings icon is clicked
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white, // Setting the screen background to white
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 2,
                    height: 15,
                    color: primaryColor,
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text(
                        'Edit profile',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        //Navigating to the Edit Profile screen once the forward arrow icon is clicked
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AccountDetailsPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 2,
                    height: 15,
                    color: primaryColor,
                  ),
                  Expanded(
                    child: ListTile(
                        title: const Text(
                          'Manage Calendars',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          //Navigating to the Add Calendar screen once the forward arrow icon is clicked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AddCalendarScreen()),
                          );
                        }),
                  ),
                ],
              ),
              const Divider(
                  color: Colors.grey), // This line creates a grey divider
              const SizedBox(height: 10),
              const Text(
                'Permissions',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 2,
                    height: 15,
                    color: primaryColor,
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text(
                        'Private mode',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      value: isPrivateMode,
                      activeColor: Colors.white,
                      onChanged: (bool value) {
                        setState(() {
                          isPrivateMode = value; //Returning the state of the bool defined at the top of this code 
                        });
                      },
                      activeTrackColor:
                          primaryColor, 
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 410), 
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    //Logging out of the application once the button is clicked
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, 
                  ),
                  child: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
