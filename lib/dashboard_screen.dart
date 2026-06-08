import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan anda tambah ini
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_user.dart';
import 'firestore_service.dart';
import 'app_theme.dart';
import 'profile_screen.dart';
import 'marketplace_screen.dart';
import 'transport_screen.dart';
import 'driver_screen.dart';
import 'my_services_screen.dart';
import 'all_services_screen.dart';
import 'chat_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final store = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: StreamBuilder<AppUser?>(
        stream: store.userStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (!snap.hasData || snap.data == null) {
            return const Center(child: Text("Welcome to UTHM Hub"));
          }

          final user = snap.data!;
          final List<Map<String, dynamic>> menuItems = [
            {
              'title': 'Marketplace',
              'icon': Iconsax.shop,
              'onTap': () => _nav(context, const MarketplaceScreen())
            },
            {
              'title': 'Services',
              'icon': Iconsax.briefcase,
              'onTap': () => _nav(context, const AllServicesScreen())
            },
            user.isDriver
                ? {
                    'title': 'Driver Hub',
                    'icon': Iconsax.car,
                    'onTap': () => _nav(context, const DriverScreen())
                  }
                : {
                    'title': 'Book Ride',
                    'icon': Iconsax.location,
                    'onTap': () => _nav(context, const TransportScreen())
                  },
          ];

          if (user.isProvider) {
            menuItems.add({
              'title': 'My Services',
              'icon': Iconsax.edit,
              'onTap': () => _nav(context, MyServicesScreen())
            });
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight:
                    150, // Ditinggikan sedikit untuk muat logo besar
                pinned: true,
                backgroundColor: AppColors.accent,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo lebih besar (height: 50)
                      Image.asset(
                        'assets/images/logo.png',
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      // Font estetik
                      Text(
                        "UTHM Hub",
                        style: GoogleFonts.dancingScript(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, Colors.blue.shade900],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                      icon:
                          const Icon(Iconsax.message_text, color: Colors.white),
                      onPressed: () => _nav(context, const ChatListScreen())),
                  IconButton(
                      icon: const Icon(Iconsax.user, color: Colors.white),
                      onPressed: () => _nav(context, const ProfileScreen())),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 10),
                    Text(getGreeting(),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 16)),
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent)),
                    const SizedBox(height: 25),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: menuItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, i) => _gridItem(
                          menuItems[i]['title'],
                          menuItems[i]['icon'],
                          menuItems[i]['onTap']),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _gridItem(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, size: 35, color: AppColors.accent),
            ),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _nav(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}
