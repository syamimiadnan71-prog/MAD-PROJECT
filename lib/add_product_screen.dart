import 'package:flutter/material.dart';
import 'firestore_service.dart'; // Pastikan fail ini ada dalam folder yang sama

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _store = FirestoreService();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Books',
    'Electronics',
    'Clothing',
    'Food',
    'Others'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    // 1. Validation
    if (_titleCtrl.text.isEmpty ||
        _selectedCategory == null ||
        _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Panggil fungsi dari FirestoreService (tally dengan Rules)
      await _store.addProduct(
        _titleCtrl.text,
        _priceCtrl.text,
        _selectedCategory!,
        _descCtrl.text,
      );

      // 3. Jika berjaya, kembali ke Marketplace
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // 4. Print ralat ke Console untuk debug
      debugPrint("RALAT: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sell an Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Product Name")),
            TextField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: "Price (RM)"),
                keyboardType: TextInputType.number),
            TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: "Category"),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitProduct,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Post to Marketplace"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
