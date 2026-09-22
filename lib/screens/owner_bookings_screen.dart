import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  List bookings = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ApiService>().get('/bookings', auth: true, query: {'as': 'owner'});
      setState(() {
        bookings = data is List ? data : [];
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    await context.read<ApiService>().patch('/bookings/$id/status', {'status': status}, auth: true);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming bookings')),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : bookings.isEmpty
              ? const Center(child: Text('No bookings yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final b = bookings[i];
                    final listing = b['listing'] as Map? ?? {};
                    final renter = b['renter'] as Map? ?? {};
                    final status = b['status']?.toString() ?? '';
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(listing['title']?.toString() ?? 'Listing', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Renter: ${renter['full_name'] ?? '—'}'),
                          Text('${b['start_date']?.toString().split('T').first} → ${b['end_date']?.toString().split('T').first}'),
                          Text('Total: \$${b['total_amount']}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Status: $status', style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (status == 'pending')
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => _updateStatus(b['id'].toString(), 'confirmed'),
                                  child: const Text('Confirm', style: TextStyle(color: Colors.green)),
                                ),
                                TextButton(
                                  onPressed: () => _updateStatus(b['id'].toString(), 'cancelled'),
                                  child: const Text('Decline', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
