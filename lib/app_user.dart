import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String faculty;
  final String yearOfStudy;
  final String profilePictureUrl;
  final String role; // 'student', 'driver', 'provider'
  final bool isOnline;

  // New flags for your smart dashboard
  final bool isDriver;
  final bool isProvider;

  AppUser({
    required this.uid,
    required this.email,
    this.name = '',
    this.faculty = '',
    this.yearOfStudy = '',
    this.profilePictureUrl = '',
    this.role = 'student',
    this.isOnline = false,
    this.isDriver = false,
    this.isProvider = false,
  });

  // Used when creating a new user in Firestore
  Map<String, dynamic> toCreateMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'faculty': faculty,
        'yearOfStudy': yearOfStudy,
        'profilePictureUrl': profilePictureUrl,
        'role': role,
        'isOnline': isOnline,
        'isDriver': isDriver,
        'isProvider': isProvider,
        'rating': 0,
        'totalRatings': 0,
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      };

  // Used when fetching data from Firestore
  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] ?? '',
        email: m['email'] ?? '',
        name: m['name'] ?? '',
        faculty: m['faculty'] ?? '',
        yearOfStudy: m['yearOfStudy'] ?? '',
        profilePictureUrl: m['profilePictureUrl'] ?? '',
        role: m['role'] ?? 'student',
        isOnline: m['isOnline'] ?? false,
        isDriver: m['isDriver'] ?? false,
        isProvider: m['isProvider'] ?? false,
      );
}
