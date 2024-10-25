
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app/Services/google_sign_in_service.dart';
import 'package:final_app/Services/api_client.dart';
import 'package:final_app/Utils/snackbars.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCalendarScreen extends StatefulWidget {
  const AddCalendarScreen({super.key});

  @override
  _AddCalendarScreenState createState() => _AddCalendarScreenState();
}

class _AddCalendarScreenState extends State<AddCalendarScreen> {
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isGoogleCalendarEnabled = false;
  bool _isLoading = false;
  List<Map<String, String>> _calendarList = [];
  String _selectedCalendar = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCalendars();
  }

  // Load saved calendars from Firestore
  Future<void> _loadSavedCalendars() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final calendarData = await _firestore
          .collection('Google_calendar lists')
          .doc(currentUser.uid)
          .collection('calendars')
          .get();

      setState(() {
        _calendarList = calendarData.docs.map((doc) {
          return {
            'id': doc.data()['id'] as String,
            'summary': doc.data()['summary'] as String
          };
        }).toList();
      });
    }
  }

  // Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final tokens = await _googleSignInService.getTokens();

      if (tokens != null) {
        // Instantiate GoogleAuthClient with accessToken
        final client = GoogleAuthClient(tokens.accessToken);

        // Fetch and display calendars
        await _fetchAndDisplayCalendars(client);

        // Fetch and store events
        await _fetchAndStoreEvents(client);

        setState(() => _isGoogleCalendarEnabled = true);
        showSnackBar(context, 'Google Calendar synced and events stored!');
      } else {
        showSnackBar(context, 'Failed to retrieve access token.');
      }
    } catch (error) {
      print('Sign-in Error: $error');
      showSnackBar(context, 'Error during Google Sign-In.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fetch and display calendars from Google
  Future<void> _fetchAndDisplayCalendars(GoogleAuthClient client) async {
    try {
      final response = await client.get(
        Uri.parse(
            'https://www.googleapis.com/calendar/v3/users/me/calendarList'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Modified code to ensure correct types
        final calendars = (data['items'] as List<dynamic>)
            .map((e) =>
                {'id': e['id'].toString(), 'summary': e['summary'].toString()})
            .toList()
            .cast<Map<String, String>>(); // Ensure the correct type is used.

        setState(() {
          _calendarList = calendars;
        });

        // Save the calendars to Firestore for persistence
        await _saveCalendarsToFirestore(calendars);
      } else {
        throw Exception('Failed to fetch calendars');
      }
    } catch (e) {
      print('Error fetching calendars: $e');
      showSnackBar(context, 'Failed to load calendars.');
    }
  }

  // Save calendar data to Firestore
  Future<void> _saveCalendarsToFirestore(
      List<Map<String, String>> calendars) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final batch = _firestore.batch();
      final calendarRef = _firestore
          .collection('Google_calendar events')
          .doc(currentUser.uid)
          .collection('calendars');

      for (var calendar in calendars) {
        batch.set(calendarRef.doc(calendar['id']), {
          'id': calendar['id'],
          'summary': calendar['summary'],
        });
      }
      await batch.commit();
    }
  }

  // Fetch and store events in Firestore under 'calendar_events'
  Future<void> _fetchAndStoreEvents(GoogleAuthClient client) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final eventsRef = _firestore
          .collection('Google_calendar events')
          .doc(currentUser.uid)
          .collection('calendar_events');

      final calendarsSnapshot = await _firestore
          .collection('Google_calendar events')
          .doc(currentUser.uid)
          .collection('calendars')
          .get();

      for (var calendarDoc in calendarsSnapshot.docs) {
        final calendarId = calendarDoc.id;

        try {
          final events = await _fetchEventsForCalendar(client, calendarId);

          // Log the fetched events
          if (events.isEmpty) {
            print('No events found for calendar: $calendarId');
          } else {
            print('Fetched ${events.length} events for calendar: $calendarId');
            print('Sample Event: ${events.first}');
          }

          // Store events in Firestore (only proceed if events are fetched)
          final batch = _firestore.batch();
          for (var event in events) {
            final eventRef = eventsRef
                .doc(calendarId)
                .collection('events')
                .doc(event['eventId']);

            batch.set(eventRef, {
              'eventName': event['eventName'],
              'date': event['date'],
              'start': event['start'],
              'end': event['end'],
            });
          }

          await batch.commit();
          print('Events stored successfully for calendar: $calendarId');
        } catch (e) {
          print('Error storing events for calendar $calendarId: $e');
        }
      }
    } else {
      print('No authenticated user found.');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEventsForCalendar(
      GoogleAuthClient client, String calendarId) async {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    final response = await client.get(
      Uri.parse(
          'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events'
          '?timeMin=${_formatToGoogleDateTime(now)}'
          '&timeMax=${_formatToGoogleDateTime(weekFromNow)}'
          '&maxResults=100'
          '&timeZone=Africa/Johannesburg'),
      headers: {'Content-Type': 'application/json'},
    );

    print('API Response: ${response.body}'); // Log response body

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final events = data['items'] as List<dynamic>;

      return events.map((event) {
        final start = event['start']['dateTime'] ?? event['start']['date'];
        final end = event['end']['dateTime'] ?? event['end']['date'];

        return {
          'eventId': event['id'],
          'eventName': event['summary'] ?? 'No Title',
          'date': _formatDate(start),
          'start': _formatTime(start),
          'end': _formatTime(end),
        };
      }).toList();
    } else {
      print('Failed to fetch events: ${response.body}');
      throw Exception('Failed to fetch events');
    }
  }

  String _formatDate(String dateTime) {
    final parsedDate = DateTime.parse(dateTime).toLocal();
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  String _formatTime(String dateTime) {
    final parsedTime = DateTime.parse(dateTime).toLocal();
    return DateFormat('HH:mm').format(parsedTime);
  }

  String _formatToGoogleDateTime(DateTime dateTime) {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime.toUtc());
  }

  Future<void> _saveAction() async {
    if (_isGoogleCalendarEnabled) {
      showSnackBar(context, 'Your calendar has been saved!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manage Calendar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a calendar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Add your preferred calendars to sync and create new events.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 28.0),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _handleGoogleSignIn,
                      icon: const Icon(Icons.add,
                          color: Colors.white), // Icon color set to white
                      label: const Text(
                        'Add Google Calendar',
                        style: TextStyle(
                            color: Colors.white), // Text color set to white
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Button background set to blue
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  if (_calendarList.isNotEmpty) ...[
                    const Text(
                      'Your Calendars:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _calendarList.length,
                        itemBuilder: (context, index) {
                          final calendar = _calendarList[index];
                          return ListTile(
                            title: Text(
                              calendar['summary'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() {
                                _calendarList.removeAt(index);
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isGoogleCalendarEnabled ? _saveAction : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Button background set to blue
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 32.0,
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                            color: Colors.white), // Text color set to white
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
    );
  }
}


