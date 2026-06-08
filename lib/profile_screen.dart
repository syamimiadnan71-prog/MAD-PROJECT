import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'app_user.dart';
import 'firestore_service.dart';
import 'app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final store = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile Settings")),
      body: StreamBuilder<AppUser?>(
        stream: store.userStream(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Header
              const CircleAvatar(
                  radius: 50, child: Icon(Iconsax.user, size: 50)),
              const SizedBox(height: 16),
              Center(
                child: Text(user.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Center(
                  child: Text(user.email,
                      style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 30),

              // Account Roles Section
              const Text("Account Status",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),

              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("I am a Driver"),
                      secondary: const Icon(Iconsax.car),
                      value: user.isDriver,
                      onChanged: (val) =>
                          store.updateUserRole(uid, isDriver: val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text("I am a Service Provider"),
                      secondary: const Icon(Iconsax.briefcase),
                      value: user.isProvider,
                      onChanged: (val) =>
                          store.updateUserRole(uid, isProvider: val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Logout Button
              ListTile(
                title:
                    const Text("Logout", style: TextStyle(color: Colors.red)),
                leading: const Icon(Iconsax.logout, color: Colors.red),
                onTap: () => _confirmLogout(context),
              )
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close profile screen
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
