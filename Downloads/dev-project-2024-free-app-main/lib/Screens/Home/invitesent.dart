import 'package:final_app/Screens/Home/edit_event.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteSentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Invites Sent',
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('event')
              .where('created_by', isEqualTo: currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var events = snapshot.data!.docs;
            if (events.isEmpty) {
              return const Center(child: Text('No invites sent.'));
            }

            // Group events by date
            Map<String, List<DocumentSnapshot>> groupedEvents = {};
            for (var event in events) {
              String eventDate = DateFormat('yyyy-MM-dd')
                  .format((event['start_time'] as Timestamp).toDate());
              if (!groupedEvents.containsKey(eventDate)) {
                groupedEvents[eventDate] = [];
              }
              groupedEvents[eventDate]!.add(event);
            }

            // Sort the dates
            List<String> sortedDates = groupedEvents.keys.toList()
              ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                String date = groupedEvents.keys.elementAt(index);
                List<DocumentSnapshot> eventList = groupedEvents[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        DateFormat('EEEE, d MMMM').format(DateTime.parse(date)),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...eventList.map((event) {
                      return _buildEventCard(
                        context: context,
                        eventId: event.id,
                        title: event['title'],
                        startTime: event['start_time'] as Timestamp,
                        endTime: event['end_time'] as Timestamp,
                        location: event['location'],
                        participants:
                            List<String>.from(event['participants'] ?? []),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Helper function to build event cards with expandable details
  Widget _buildEventCard({
    required BuildContext context,
    required String eventId,
    required String title,
    required Timestamp startTime,
    required Timestamp endTime,
    required String location,
    List<String>? participants,
  }) {
    String formattedStartTime =
        DateFormat('hh:mm a').format(startTime.toDate());
    String formattedEndTime = DateFormat('hh:mm a').format(endTime.toDate());
    String timeRange = '$formattedStartTime - $formattedEndTime';

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
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeRange,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
        children: [
          if (participants != null && participants.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Participants:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            for (var person in participants)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.purpleAccent,
                      radius: 12,
                      child: Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(person, style: const TextStyle(color: Colors.black)),
                  ],
                ),
              ),
          ],

          // Share on Whatsapp Button
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  String message =
                      "Event: $title\nTime: $timeRange\nLocation: $location";
                  openWhatsapp(message);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/whatsapp.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Share',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Edit button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditEventScreen(eventId: eventId)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('event')
                        .doc(eventId)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Event deleted successfully.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to delete event.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Launching Whatsapp
  Future<void> openWhatsapp(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = "https://wa.me/?text=$encodedMessage";

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        print("Could not open WhatsApp");
      }
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }
}
