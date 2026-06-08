import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Messages")),
      body: StreamBuilder<QuerySnapshot>(
        // QUERY: Hanya ambil chat yang ada 'participants' mengandungi uid pengguna
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: uid)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text("No active chats."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: snap.data!.docs.length,
            separatorBuilder: (context, i) => const Divider(),
            itemBuilder: (context, index) {
              var chat = snap.data!.docs[index];
              var data = chat.data() as Map<String, dynamic>;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.chat_bubble, color: Colors.white),
                ),
                title: Text("Chat with ${data['otherUserName'] ?? 'User'}"),
                subtitle: Text(data['lastMessage'] ?? "Start conversation"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(chatId: chat.id, title: "Chat"),
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
