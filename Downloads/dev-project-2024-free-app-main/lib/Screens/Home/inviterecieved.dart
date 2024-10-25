import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InviteReceivedScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InviteReceivedScreen extends StatelessWidget {
  const InviteReceivedScreen({super.key});

  Future<Map<String, String?>> getCurrentUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user == null) return {};

    // Fetch the user's details from the 'User' collection
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('User').doc(user.uid).get();

    return {
      'userId': user.uid,
      'firstName': userDoc['first_name'] ?? '',
      'lastName': userDoc['last_name'] ?? '',
    };
  }

  Stream<QuerySnapshot> fetchFilteredEvents(String userId, String fullName) {
    return FirebaseFirestore.instance
        .collection('event')
        .where('created_by',
            isNotEqualTo:
                userId) // Filter out events created by the current user
        .snapshots();
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEEE, d MMMM').format(dateTime);
  }

  String formatTime(dynamic timeField) {
    if (timeField is Timestamp) {
      DateTime time =
          timeField.toDate(); // Convert to DateTime if it's a Timestamp
      return DateFormat('HH:mm').format(time);
    } else if (timeField is String) {
      return timeField;
    } else {
      return '00:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: getCurrentUserInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final userId = snapshot.data!['userId']!;
        final fullName =
            '${snapshot.data!['firstName']} ${snapshot.data!['lastName']}';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Invites Received',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: StreamBuilder<QuerySnapshot>(
              stream: fetchFilteredEvents(userId, fullName),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading events'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final eventDocs = snapshot.data?.docs ?? [];

                // Group events by date
                Map<String, List<QueryDocumentSnapshot>> eventsByDate = {};

                for (var doc in eventDocs) {
                  List<String> participants =
                      List<String>.from(doc['participants'] ?? []);

                  // Filter events where the user's full name appears in the participants
                  if (!participants.contains(fullName)) {
                    continue;
                  }

                  Timestamp eventDate = doc['date'];
                  String formattedDate = formatDate(eventDate);

                  // If this date already exists in the map, add the event to the list; otherwise create a new list
                  if (eventsByDate.containsKey(formattedDate)) {
                    eventsByDate[formattedDate]!.add(doc);
                  } else {
                    eventsByDate[formattedDate] = [doc];
                  }
                }

                // Sort the dates in ascending order (latest first)
                var sortedDates = eventsByDate.keys.toList()
                  ..sort((a, b) {
                    DateTime dateA = DateFormat('EEEE, d MMMM').parse(a);
                    DateTime dateB = DateFormat('EEEE, d MMMM').parse(b);
                    return dateA.compareTo(dateB);
                  });

                // Build the UI
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDates.length, 
                  itemBuilder: (context, index) {
                    String date = sortedDates[index]; 
                    List<QueryDocumentSnapshot> eventsOnThisDate =
                        eventsByDate[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(date),
                        // Loop through the events for this particular date
                        ...eventsOnThisDate.map((event) {
                          final title = event['title'] ?? 'No Title';

                          // Convert start_time and end_time to time format
                          final startTime = formatTime(event['start_time']);
                          final endTime = formatTime(event['end_time']);

                          final participants =
                              List<String>.from(event['participants'] ?? []);
                          final location =
                              event['location'] ?? 'No Location Specified';

                          final time = '$startTime - $endTime';

                          // Get the event ID
                          final eventId =
                              event.id; // Use the document ID for the event

                          return EventCard(
                            title: title,
                            time: time,
                            location: location, 
                            participants: participants,
                            eventId:
                                eventId, // Pass the event ID to the EventCard
                          );
                        }).toList(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          date,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final String title;
  final String time;
  final String location;
  final List<String> participants;
  final String eventId;

  const EventCard({
    Key? key,
    required this.title,
    required this.time,
    required this.location,
    required this.participants,
    required this.eventId,
  }) : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String? _responseMessage; // To hold the response message

  void _acceptEvent() {
    setState(() {
      _responseMessage = 'Accepted event invite';
    });
  }

  void _declineEvent() async {
    setState(() {
      _responseMessage = 'Declined event invite';
    });

    // Remove the user's name from the participants list in Firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String fullName = '${user.displayName}';
      await FirebaseFirestore.instance
          .collection('event')
          .doc(widget.eventId)
          .update({
        'participants': FieldValue.arrayRemove([fullName]),
      });

      // Check if the widget is still mounted before navigating
      if (mounted) {
        Navigator.of(context)
            .pop(); // This will remove the card if you navigate back
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
            color: Color.fromARGB(255, 48, 17, 133), width: 2.0),
      ),
      color: Colors.white,
      child: ExpansionTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            Text(
              widget.time,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              widget.location,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Participants:',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          // Displaying the list of participants
          for (var participant in widget.participants)
            Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.purpleAccent,
                    radius: 12,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    participant,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Show the message if a response was given
          if (_responseMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _responseMessage!,
                style: TextStyle(
                  color: _responseMessage!.startsWith('Accepted')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else ...[
            // Action buttons (Accept, Decline)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _acceptEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
                ElevatedButton(
                  onPressed: _declineEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
