import 'package:final_app/Screens/Home/create_event.dart';
import 'package:final_app/Screens/Home/inviterecieved.dart';
import 'package:flutter/material.dart';
import 'package:final_app/Screens/Settings/settingsscreen.dart';
import 'package:final_app/Screens/Home/invitesent.dart';
import 'package:final_app/Screens/Home/invite_external_connections.dart';
import 'package:table_calendar/table_calendar.dart'; 
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

// primary colors
const Color primaryColor = Color.fromARGB(255, 50, 81, 239);
const Color primaryLightColor = Colors.blueAccent;
const Color primaryDarkColor = Colors.indigo;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key, required Map events});

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 2;
  int invitesSentCount = 0; // To store the count of invites sent
  int invitesReceivedCount = 0; // To store the count of invites received

  // State variables to hold event data and loading state
  List<Event> events = []; // Store fetched events
  bool isLoading = true; 
  String? userImageUrl; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchEvents(); // Fetch events when the screen is initialized
    fetchInvitesSentCount(); // Fetch the count of invites sent
    fetchInvitesReceivedCount(); // fetch the count of invites received
    _scrollController.addListener(() {
      setState(() {});
    });
    // Get the current user's profile image URL
    final User? user = FirebaseAuth.instance.currentUser;
    userImageUrl = user?.photoURL ??
        'https://via.placeholder.com/150'; // Default image if null
  }

   // Fetch the count of events created by the current authenticated user
  Future<void> fetchInvitesSentCount() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('event')
          .where('created_by', isEqualTo: user.uid) // Filter by user ID
          .get();

      setState(() {
        invitesSentCount = snapshot.docs.length; 
      });
    }
  }

 // Fetch the count of events where the current user is a participant
  Future<void> fetchInvitesReceivedCount() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch the user's first and last name from Firestore
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;

      final String firstName = userData?['first_name'] ?? '';
      final String lastName = userData?['last_name'] ?? '';

      // Query the events where the user is a participant
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('event')
          .where('participants', arrayContains: '$firstName $lastName')
          .get();

      setState(() {
        invitesReceivedCount = snapshot.docs.length; 
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

 // Fetch events from Firestore
Future<void> fetchEvents() async {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Fetch the user's first and last name from Firestore
    final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(user.uid)
        .get();
    final userData = userSnapshot.data() as Map<String, dynamic>?;

    final String firstName = userData?['first_name'] ?? '';
    final String lastName = userData?['last_name'] ?? '';

    // Fetch events created by the user
    final QuerySnapshot createdEventsSnapshot = await FirebaseFirestore.instance
        .collection('event')
        .where('created_by', isEqualTo: user.uid)
        .get();

    // Fetch events where the user is a participant
    final QuerySnapshot participantEventsSnapshot = await FirebaseFirestore.instance
        .collection('event')
        .where('participants', arrayContains: '$firstName $lastName')
        .get();

    // Combine both event lists and remove duplicates
    List<Event> fetchedEvents = [];
    fetchedEvents.addAll(createdEventsSnapshot.docs.map((doc) {
      return Event.fromFirestore(doc.data() as Map<String, dynamic>);
    }));

    fetchedEvents.addAll(participantEventsSnapshot.docs.map((doc) {
      return Event.fromFirestore(doc.data() as Map<String, dynamic>);
    }));

    // Use a Set to filter duplicates
    final uniqueEvents = {
      for (var event in fetchedEvents) event.title: event
    }.values.toList();

    setState(() {
      // Filter events based on current time
      events = uniqueEvents
          .where((event) => event.endTime.isAfter(DateTime.now()))
          .toList();
      // Sort events by start time
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
      // Limit to only the closest 4 upcoming events
      events = events.take(4).toList();
      isLoading = false; // Set loading to false after fetching
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.jpg', 
          height: 100.0, 
        ),
        automaticallyImplyLeading: false, // This removes the back button
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LandingScreen(
                                events: {},
                              )),
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white, // Set the entire page background to white
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Calendar',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Upcoming Events',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // ListView to display events
              SizedBox(
                height: 170,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(Colors.black),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: isLoading
                            ? 3
                            : events
                                .length, 
                        itemBuilder: (context, index) {
                          if (isLoading) {
                            return const Center(
                                child:
                                    CircularProgressIndicator()); 
                          }

                          Event event = events[index];
                          return EventCard(
                            title: event.title,
                            time:
                                '${DateFormat.jm().format(event.startTime)} - ${DateFormat.jm().format(event.endTime)}', // Format time as desired
                            imageUrl: userImageUrl ??
                                'https://via.placeholder.com/150', // Use a placeholder if userImageUrl is null
                            onTap: () {
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Invitations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              InvitationsCard(
                title: 'Invites Sent ($invitesSentCount)', // Use the dynamic count
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  InviteSentScreen()),
                  );
                },
              ),
              InvitationsCard(
                title: 'Invites Received ($invitesReceivedCount)', // Display dynamic invites received count
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const InviteReceivedScreen()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center, // Keeps the text centered
                    clipBehavior:
                        Clip.none, // Ensures the button doesn't get clipped
                    children: [
                      const Text(
                        'Schedule',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .end, 
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape:
                                  const CircleBorder(), 
                              padding: const EdgeInsets.all(
                                  10), 
                              backgroundColor:
                                  Colors.blue, 
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateEventScreen(),
                                ), 
                              );
                            },
                            child: const Icon(
                              Icons.add,
                              color: Colors.white, 
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const CalendarWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// Event data model
class Event {
  final String title;
  final DateTime startTime;
  final DateTime endTime;

  Event({required this.title, required this.startTime, required this.endTime});

  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      title: data['title'] ?? 'No Title', // Default value if title is null
      startTime: (data['start_time'] as Timestamp?)?.toDate() ??
          DateTime.now(), // Default to current time if null
      endTime: (data['end_time'] as Timestamp?)?.toDate() ??
          DateTime.now().add(
              const Duration(hours: 1)), // Default to one hour later if null
    );
  }
}

// EventCard and InvitationsCard widgets 
class EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String imageUrl;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.title,
    required this.time,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
            color: Color.fromARGB(255, 48, 17, 133), width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.black)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class InvitationsCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const InvitationsCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
            color: Color.fromARGB(255, 48, 17, 133), width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        trailing: const Icon(
            Icons.arrow_forward_ios), // This places the icon at the right
        onTap: onTap,
      ),
    );
  }
}

// CalendarWidget (integrated)
class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  bool _isExpanded = false; // Track if the calendar is expanded

  // This will store the events fetched from Firestore
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _fetchEvents(); // Fetch events when the widget is initialized
  }

  // Method to fetch events from Firestore
  Future<void> _fetchEvents() async {
    // Reference the Firestore 'event' collection
    CollectionReference eventsCollection = FirebaseFirestore.instance.collection('event');

    try {
      QuerySnapshot querySnapshot = await eventsCollection.get();

      // Iterate over the documents and process the event data
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Assuming your event document has 'date', 'start_time', 'end_time', 'location', and 'title' fields
        Timestamp timestamp = data['date'];
        DateTime eventDate = timestamp.toDate();
        String eventTitle = data['title'];
        Timestamp startTime = data['start_time'];
        Timestamp endTime = data['end_time'];
        String location = data['location'];

        // Convert to DateTime objects
        DateTime eventDay = DateTime.utc(eventDate.year, eventDate.month, eventDate.day);
        String formattedStartTime = DateFormat.jm().format(startTime.toDate());
        String formattedEndTime = DateFormat.jm().format(endTime.toDate());

        // Store event data 
        Map<String, dynamic> eventDetails = {
          'title': eventTitle,
          'time': '$formattedStartTime - $formattedEndTime',
          'location': location,
        };

        // Store events by date in the _events map
        if (_events[eventDay] == null) {
          _events[eventDay] = [];
        }
        _events[eventDay]!.add(eventDetails);
      });

      setState(() {
        // Update the UI after fetching events
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 48, 17, 133),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildMonthCalendar(), 
          if (_isExpanded) _buildDayView(), 
        ],
      ),
    );
  }

  // Method to build the month calendar
  Widget _buildMonthCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay; 
          _isExpanded = true; 
        });
      },
      eventLoader: (day) {
        // Check if the day has any events in Firestore
        return _events[day]?.map((event) => event['title']).toList() ?? [];
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false, 
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color.fromARGB(255, 50, 81, 239),
          shape: BoxShape.circle,
        ),
        defaultDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.green, 
          shape: BoxShape.circle,
        ),
      ),
      startingDayOfWeek:
          StartingDayOfWeek.monday, 
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          // Display only a green dot and the event count
          if (events.isNotEmpty) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.circle,
                    size: 6,
                    color: Colors.green, 
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${events.length}', 
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  // Method to build the day view of events
  Widget _buildDayView() {
    List<Map<String, dynamic>> events = _events[_selectedDay] ?? [];

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'Events on ${DateFormat.yMMMMd().format(_selectedDay)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200, 
          child: Scrollbar(
            thickness: 8.0, 
            radius: const Radius.circular(10), 
            child: SingleChildScrollView(
              child: Column(
                children: events.isNotEmpty
                    ? events.map((event) {
                        return ListTile(
                          title: Text(event['title']),
                          subtitle: Text('Time: ${event['time']}\nLocation: ${event['location']}'),
                        );
                      }).toList()
                    : const [Center(child: Text('No events for this day'))],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), 
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isExpanded = false; 
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, 
            foregroundColor: Colors.white, 
          ),
          child: const Text('Collapse'),
        ),
      ],
    );
  }
}