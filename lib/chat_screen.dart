import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'app_theme.dart'; // Menggunakan tema anda

class ChatScreen extends StatelessWidget {
  final String chatId; // ID transaksi (product/service/ride ID)
  final String title; // Tajuk (Contoh: "Chat dengan Penjual")

  ChatScreen({super.key, required this.chatId, required this.title});

  final _msgCtrl = TextEditingController();
  final _store = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // 1. Senarai Mesej (Real-time)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _store.getMessages(chatId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.accent));
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("Start a conversation!",
                          style: TextStyle(color: AppColors.grey)));
                }

                final msgs = snap.data!.docs;
                return ListView.builder(
                  reverse: true, // Supaya mesej terkini di bawah
                  itemCount: msgs.length,
                  itemBuilder: (context, i) => _buildMessage(msgs[i]),
                );
              },
            ),
          ),

          // 2. Ruang Input Mesej
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child:
                        const Icon(Icons.send_rounded, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    _store.sendMessage(
        chatId, _msgCtrl.text.trim(), user.uid, user.displayName ?? "User");
    _msgCtrl.clear();
  }

  // 3. Reka bentuk gelembung mesej
  Widget _buildMessage(QueryDocumentSnapshot msg) {
    bool isMe = msg['senderId'] == user.uid;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppColors.accent : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(20),
              ),
              border: isMe ? null : Border.all(color: AppColors.border),
            ),
            child: Text(
              msg['text'],
              style: TextStyle(
                  color: isMe ? AppColors.white : Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
