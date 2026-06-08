import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'firestore_service.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final _store = FirestoreService();
  final _destCtrl = TextEditingController();
  GoogleMapController? _mapController;
  bool _isSearching = false;
  LatLng _selectedLocation = const LatLng(1.8596, 103.0763); // Default UTHM
  String _addressName = "Loading...";

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  // 1. Dapatkan lokasi asal pengguna
  Future<void> _initPosition() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng myPos = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(myPos));
      setState(() => _selectedLocation = myPos);
      _getAddress(myPos);
    } catch (e) {
      _getAddress(_selectedLocation); // Guna default jika gagal
    }
  }

  // 2. Fungsi Translate LatLng ke Nama Tempat
  Future<void> _getAddress(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        setState(() =>
            _addressName = "${p.street ?? p.name ?? ''}, ${p.locality ?? ''}");
      }
    } catch (e) {
      setState(() => _addressName = "Tap map to detect location");
    }
  }

  // 3. Butang Book Ride
  void _bookRide() async {
    if (_destCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Masukkan destinasi!")));
      return;
    }

    setState(() => _isSearching = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _store.requestRide(user.uid, _selectedLocation, _destCtrl.text);
      if (mounted) Navigator.pop(context);
    }
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _selectedLocation, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (c) => _mapController = c,
            // Detek lokasi bila map berhenti gerak
            onCameraIdle: () async {
              LatLngBounds bounds = await _mapController!.getVisibleRegion();
              LatLng center = LatLng(
                (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
              );
              setState(() => _selectedLocation = center);
              _getAddress(center);
            },
          ),
          // Pin di tengah skrin
          const Center(
              child: Icon(Icons.location_pin, color: Colors.red, size: 40)),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Text(_addressName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _destCtrl,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Destinasi anda..."),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _bookRide,
              child: _isSearching
                  ? const CircularProgressIndicator()
                  : const Text("Confirm Ride"),
            ),
          )
        ],
      ),
    );
  }
}
