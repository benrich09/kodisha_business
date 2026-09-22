import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  List listings = [];
  List categories = [];
  bool loading = true;
  String? error;
  final _search = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = context.read<ApiService>();
      final catRes = await api.get('/categories');
      final listRes = await api.get('/listings', query: {
        if (selectedCategory != null) 'category_id': selectedCategory!,
        if (_search.text.isNotEmpty) 'q': _search.text.trim(),
      });
      setState(() {
        categories = catRes is List ? catRes : [];
        listings = listRes is Map ? (listRes['data'] as List? ?? []) : [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDiscover(),
      const SizedBox(), // bookings handled by route
      const SizedBox(),
      const SizedBox(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _tab == 0 ? 0 : 0,
        children: [
          _buildDiscover(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) {
          if (i == 1) {
            Navigator.pushNamed(context, '/bookings');
            return;
          }
          if (i == 2) {
            Navigator.pushNamed(context, '/favorites');
            return;
          }
          if (i == 3) {
            Navigator.pushNamed(context, '/profile');
            return;
          }
          setState(() => _tab = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDiscover() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.key_rounded, color: AppTheme.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Kodisha',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Search anything to rent…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _load,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('All', selectedCategory == null, () {
                  setState(() => selectedCategory = null);
                  _load();
                }),
                ...categories.map((c) {
                  final id = c['id']?.toString();
                  final name = c['name']?.toString() ?? '';
                  final icon = c['icon']?.toString() ?? '';
                  return _chip('$icon $name', selectedCategory == id, () {
                    setState(() => selectedCategory = id);
                    _load();
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _load, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : listings.isEmpty
                        ? const Center(child: Text('No listings yet. Check back soon!'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppTheme.primary,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: listings.length,
                              itemBuilder: (_, i) => ListingCard(
                                listing: listings[i],
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/listing',
                                  arguments: listings[i]['id'].toString(),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 13)),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primary.withOpacity(0.15),
        checkmarkColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
