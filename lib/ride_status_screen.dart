import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart'; // Pastikan anda guna ikon ini
import 'chat_screen.dart'; // MESTI IMPORT CHAT SCREEN

class RideStatusScreen extends StatelessWidget {
  final String rideId;

  const RideStatusScreen({super.key, required this.rideId});

  Future<void> updateRideStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'status': newStatus,
        'driverId': FirebaseAuth.instance.currentUser?.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ride Status")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Ride tidak ditemui."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String status = data['status'] ?? 'pending';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("STATUS: ${status.toUpperCase()}",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  // LOGIK PAPARAN
                  if (status == 'pending') ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    const Text("Sedang mencari pemandu..."),
                  ] else if (status == 'accepted') ...[
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 80),
                    const Text("Pemandu dalam perjalanan!",
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),

                    // BUTANG CHAT (Hanya muncul jika accepted)
                    ElevatedButton.icon(
                      icon: const Icon(Iconsax.messages),
                      label: const Text("Chat dengan Pemandu"),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                                chatId: rideId, title: "Chat dengan Pemandu"),
                          )),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => updateRideStatus(context, 'completed'),
                      child: const Text("Tamatkan Perjalanan"),
                    ),
                  ] else if (status == 'completed') ...[
                    const Icon(Icons.flag, color: Colors.blue, size: 80),
                    const Text("Perjalanan tamat. Terima kasih!"),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
