import 'package:flutter/material.dart';

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
        side: const BorderSide(color: Color.fromARGB(255, 48, 17, 133), width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        side: const BorderSide(color: Color.fromARGB(255, 48, 17, 133), width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        trailing: const Icon(Icons.arrow_forward_ios), // This places the icon at the right
        onTap: onTap,
      ),
    );
  }
}
