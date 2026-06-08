import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'firestore_service.dart';
import 'add_product_screen.dart';
import 'chat_screen.dart'; // Import chat_screen.dart yang kita bina tadi

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirestoreService _store = FirestoreService();
  final List<String> categories = [
    'All',
    'Electronics',
    'Books',
    'Furniture',
    'Stationery'
  ];
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marketplace")),
      body: Column(
        children: [
          // Kategori Filter
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: selectedCategory == categories[index],
                  onSelected: (bool selected) =>
                      setState(() => selectedCategory = categories[index]),
                ),
              ),
            ),
          ),

          // Senarai Produk
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _store.getProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs;
                if (selectedCategory != 'All') {
                  docs = docs
                      .where((doc) =>
                          (doc.data() as Map)['category'] == selectedCategory)
                      .toList();
                }

                if (docs.isEmpty)
                  return const Center(child: Text("No items found"));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    String docId = docs[index].id; // ID unik untuk Chat

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(data['title'] ?? 'No Title'),
                        subtitle: Text(
                            "RM ${data['price'] ?? '0'} | ${data['category']}"),
                        trailing: IconButton(
                          icon:
                              const Icon(Iconsax.messages, color: Colors.blue),
                          onPressed: () {
                            // INTEGRASI CHAT: Navigasi ke ChatScreen dengan docId produk
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: docId,
                                  title: "Chat with Seller: ${data['title']}",
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddProductScreen())),
        child: const Icon(Iconsax.add),
      ),
    );
  }
}
