import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _deposit = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  List categories = [];
  String? categoryId;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCats();
  }

  Future<void> _loadCats() async {
    try {
      final data = await context.read<ApiService>().get('/categories');
      setState(() => categories = data is List ? data : []);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_title.text.isEmpty || categoryId == null || _price.text.isEmpty) {
      setState(() => error = 'Title, category and daily price are required');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final body = {
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'category_id': categoryId,
        'price_daily': double.tryParse(_price.text) ?? 0,
        'security_deposit': double.tryParse(_deposit.text) ?? 0,
        'city': _city.text.trim(),
        'address': _address.text.trim(),
        'status': 'active',
        'currency': 'USD',
      };
      await context.read<ApiService>().post('/listings', body, auth: true);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(error!, style: TextStyle(color: Colors.red.shade700)),
              ),
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: _desc, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((c) => DropdownMenuItem(value: c['id']?.toString(), child: Text('${c['icon'] ?? ''} ${c['name']}')))
                  .toList(),
              onChanged: (v) => setState(() => categoryId = v),
            ),
            const SizedBox(height: 12),
            TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily price (USD)', prefixText: '\$ ')),
            const SizedBox(height: 12),
            TextField(controller: _deposit, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Security deposit', prefixText: '\$ ')),
            const SizedBox(height: 12),
            TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 12),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Publish listing'),
            ),
          ],
        ),
      ),
    );
  }
}
