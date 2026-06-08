import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  // Fungsi untuk buka Google Maps Pemandu
  Future<void> _launchMaps(String latLong) async {
    final Uri googleMapsUrl =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$latLong");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incoming Rides")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final rides = snapshot.data!.docs;

          if (rides.isEmpty)
            return const Center(child: Text("No rides available."));

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              final data = ride.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, color: Colors.blue),
                  title: Text("Pickup: ${data['pickup']}"),
                  subtitle: Text("To: ${data['destination']}"),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // 1. Update Firestore
                      await ride.reference.update({
                        'status': 'accepted',
                        'driverId': FirebaseAuth.instance.currentUser?.uid,
                      });
                      // 2. Terus buka Google Maps untuk pemandu
                      await _launchMaps(data['pickup']);
                    },
                    child: const Text("Accept"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
