import 'package:final_app/Screens/Home/invitesent.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InviteSentScreen(),
    );
  }
}

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();

  final List<String> _selectedUsers = [];
  List<String> _suggestedUsers = [];
  final Map<String, List<String>> _availabilityData = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString();
    _fetchEventData(); // Fetch event data when the screen initializes
  }

  // Fetch event data from Firestore using eventId
  Future<void> _fetchEventData() async {
    try {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('event')
          .doc(widget.eventId)
          .get();
      if (eventDoc.exists) {
        var data = eventDoc.data() as Map<String, dynamic>;

        _titleController.text = data['title'] ?? '';
        _dateController.text =
            (data['date'] as Timestamp).toDate().toString().split(' ')[0];
        _startTimeController.text = DateFormat.jm()
            .format((data['start_time'] as Timestamp).toDate()); 
        _endTimeController.text = DateFormat.jm().format(
            (data['end_time'] as Timestamp)
                .toDate()); // AM/PM format// Extract time
        _locationController.text = data['location'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _selectedUsers.addAll(List<String>.from(data['participants'] ?? []));

        setState(() {}); // 
      } else {
        _showDialog('Error', 'Event not found.');
      }
    } catch (e) {
      print('Error fetching event data: $e');
      _showDialog('Error', 'Failed to load event data: $e');
    }
  }

  // Fetch users from Firestore based on search query
  Future<void> _fetchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestedUsers = [];
      });
      return;
    }

    try {
      // Fetch all users from Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('User').get();

      // Filter users based on the search query (case insensitive)
      setState(() {
        _suggestedUsers = snapshot.docs
            .map((doc) {
              String firstName = doc['first_name'] as String;
              String lastName = doc['last_name'] as String;
              return '$firstName $lastName';
            })
            .where((user) => user.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Edit Event',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Enter event title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Participants Search Field
            const Text(
              'Participants',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _participantsController,
              decoration: const InputDecoration(
                labelText: 'Search for participants',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _fetchUsers(value); // Fetch users from Firestore as user types
              },
            ),
            const SizedBox(height: 10),

            // Show search results
            if (_participantsController.text.isNotEmpty)
              Column(
                children: _suggestedUsers
                    .map((user) => ListTile(
                          leading: CircleAvatar(child: Text(user[0])),
                          title: Text(user),
                          trailing: Checkbox(
                            value: _selectedUsers.contains(user),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedUsers.add(user);
                                } else {
                                  _selectedUsers.remove(user);
                                }
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            Wrap(
              children: _selectedUsers
                  .map((user) => Chip(
                        label: Text(user),
                        onDeleted: () {
                          setState(() {
                            _selectedUsers.remove(user);
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Date and Time Fields
            const Text(
              'Date and Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Pick a Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text = pickedDate.toString().split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      labelText: 'Start Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _startTimeController.text =
                              pickedTime.format(context);
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      labelText: 'End Time',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _endTimeController.text = pickedTime.format(context);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Location Input
            const Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Enter location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Description Input
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Enter event description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Edit Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent() async {
    String title = _titleController.text;
    String date = _dateController.text;
    String startTime = _startTimeController.text;
    String endTime = _endTimeController.text;
    String location = _locationController.text;
    String description = _descriptionController.text;
    String reminder = _reminderController.text;

    if (title.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        location.isEmpty) {
      _showDialog('Error', 'Please fill in all the required fields.');
      return;
    }

    // Date and time parsing logic
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateFormat timeFormat = DateFormat.jm();
    try {
      // Get the current authenticated user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        _showDialog('Error', 'No user is currently logged in.');
        return;
      }

      // Parse date and times
      DateTime selectedDate = dateFormat.parse(date);
      DateTime startDateTime =
          DateFormat('yyyy-MM-dd hh:mm a').parse('$date $startTime');
      DateTime endDateTime =
          DateFormat('yyyy-MM-dd hh:mm a').parse('$date $endTime');

      // Convert DateTime to Firestore Timestamp
      Timestamp eventDate = Timestamp.fromDate(selectedDate);
      Timestamp startTimestamp = Timestamp.fromDate(startDateTime);
      Timestamp endTimestamp = Timestamp.fromDate(endDateTime);

      // Update the event document in the Firestore collection
      await FirebaseFirestore.instance
          .collection('event')
          .doc(widget.eventId)
          .update({
        'title': title,
        'date': eventDate,
        'start_time': startTimestamp,
        'end_time': endTimestamp,
        'location': location,
        'description': description,
        'reminder': reminder,
        'participants': _selectedUsers,
        'updated_at': Timestamp.now(),
      });

      _showDialog('Event edited', 'Your event has been successfully edited.');
    } catch (e) {
      _showDialog('Error', 'Failed to edit event: $e');
    }
  }

  // Firestore event creation logic remains unchange
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => InviteSentScreen()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
