import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  Map? listing;
  bool loading = true;
  String? error;
  DateTimeRange? range;
  bool booking = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ApiService>().get('/listings/${widget.listingId}');
      setState(() {
        listing = Map<String, dynamic>.from(data as Map);
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _book() async {
    if (range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dates')),
      );
      return;
    }
    setState(() => booking = true);
    try {
      await context.read<ApiService>().post('/bookings', {
        'listing_id': widget.listingId,
        'start_date': range!.start.toIso8601String().split('T').first,
        'end_date': range!.end.toIso8601String().split('T').first,
        'pricing_type': 'daily',
      }, auth: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request sent!')),
        );
        Navigator.pushNamed(context, '/bookings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
    }
    if (error != null || listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(error ?? 'Not found')),
      );
    }

    final media = listing!['media'] as List? ?? [];
    final title = listing!['title'] ?? '';
    final desc = listing!['description'] ?? '';
    final price = listing!['price_daily'];
    final deposit = listing!['security_deposit'] ?? 0;
    final city = listing!['city'] ?? '';
    final owner = listing!['owner'] as Map? ?? {};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: media.isNotEmpty
                  ? PageView.builder(
                      itemCount: media.length,
                      itemBuilder: (_, i) => Image.network(
                        media[i]['url']?.toString() ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                      ),
                    )
                  : Container(
                      color: AppTheme.primary.withOpacity(0.1),
                      child: const Icon(Icons.image, size: 64, color: AppTheme.primary),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () async {
                  try {
                    await context.read<ApiService>().post('/favorites/${widget.listingId}', {}, auth: true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved to favorites')),
                    );
                  } catch (_) {}
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  if (city.toString().isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(city.toString(), style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (price != null)
                    Text(
                      '\$$price / day',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  if (deposit > 0)
                    Text('Security deposit: \$$deposit', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 20),
                  const Text('About', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(desc.toString(), style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: Text(
                        (owner['full_name']?.toString() ?? 'O')[0].toUpperCase(),
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(owner['full_name']?.toString() ?? 'Owner', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(owner['is_verified'] == true ? 'Verified owner' : 'Owner'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => range = picked);
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      range == null
                          ? 'Select dates'
                          : '${range!.start.toString().split(' ').first} → ${range!.end.toString().split(' ').first}',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: booking ? null : _book,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: booking
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Request to book'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
