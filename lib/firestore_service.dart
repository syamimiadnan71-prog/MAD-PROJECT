import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. USER MANAGEMENT ---
  Future<void> createUserIfMissing(AppUser user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set(user.toCreateMap());
    }
  }

  Stream<AppUser?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) return AppUser.fromMap(snapshot.data()!);
      return null;
    });
  }

  Future<void> updateUserRole(String uid,
      {bool? isDriver, bool? isProvider}) async {
    final Map<String, dynamic> data = {};
    if (isDriver != null) data['isDriver'] = isDriver;
    if (isProvider != null) data['isProvider'] = isProvider;
    await _db.collection('users').doc(uid).update(data);
  }

  // --- 2. MARKETPLACE ---
  Future<void> addProduct(
      String title, String price, String category, String description) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User tidak dijumpai");
    await _db.collection('products').add({
      'title': title,
      'price': price,
      'category': category,
      'description': description,
      'sellerUid': user.uid,
      'sellerEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getProducts() => _db
      .collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> deleteProduct(String docId) =>
      _db.collection('products').doc(docId).delete();

  // --- 3. TRANSPORT (RIDE) ---
  Future<String?> requestRide(
      String passengerUid, LatLng pickup, String destination) async {
    final docRef = await _db.collection('rides').add({
      'passengerUid': passengerUid,
      'pickup': GeoPoint(pickup.latitude, pickup.longitude),
      'destination': destination,
      'status': 'searching',
      'timestamp': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> acceptRide(String rideId, String driverUid) async {
    await _db.collection('rides').doc(rideId).update({
      'status': 'accepted',
      'driverUid': driverUid,
      'acceptedAt': FieldValue.serverTimestamp()
    });
  }

  Stream<QuerySnapshot> getAvailableRides() => _db
      .collection('rides')
      .where('status', isEqualTo: 'searching')
      .orderBy('timestamp', descending: true)
      .snapshots();

  Stream<DocumentSnapshot> getRideStatus(String rideId) =>
      _db.collection('rides').doc(rideId).snapshots();

  Future<void> updateRideStatus(String rideId, String status) async {
    await _db.collection('rides').doc(rideId).update({'status': status});
  }

  // --- 4. STUDENT SERVICES ---
  Future<void> addService(String title, String description) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User tidak dijumpai");
    await _db.collection('services').add({
      'title': title,
      'description': description,
      'providerUid': user.uid,
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  Stream<QuerySnapshot> getMyServices(String providerUid) => _db
      .collection('services')
      .where('providerUid', isEqualTo: providerUid)
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<void> deleteService(String docId) async =>
      await _db.collection('services').doc(docId).delete();

  Stream<QuerySnapshot> getServices() => _db
      .collection('services')
      .orderBy('createdAt', descending: true)
      .snapshots();

  // --- 5. UNIFIED CHAT SYSTEM ---
  Future<void> sendMessage(
      String chatId, String text, String senderId, String senderName) async {
    final chatRef = _db.collection('chats').doc(chatId);

    // 1. Simpan mesej ke dalam sub-koleksi
    await chatRef.collection('messages').add({
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. Update metadata untuk paparan senarai chat
    // Menggunakan arrayUnion untuk menambah ID pengirim ke senarai peserta
    await chatRef.set({
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'participants': FieldValue.arrayUnion([senderId]),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
