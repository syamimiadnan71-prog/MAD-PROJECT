import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'firestore_service.dart';
import 'chat_screen.dart'; // MESTI IMPORT CHAT SCREEN

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Warna background lembut
      appBar: AppBar(
        title: const Text("Services Offered",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: store.getServices(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No services available yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snap.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(data['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(data['description']),
                  ),
                  trailing: IconButton(
                    icon:
                        const Icon(Iconsax.messages, color: Colors.blueAccent),
                    onPressed: () {
                      // NAVIGASI KE CHAT SCREEN
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: doc.id, // ID Servis sebagai chatId
                            title: "Chat with Provider",
                          ),
                        ),
                      );
                    },
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
