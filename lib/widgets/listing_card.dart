import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ListingCard extends StatelessWidget {
  final Map listing;
  final VoidCallback onTap;

  const ListingCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final media = listing['media'] as List? ?? [];
    final image = media.isNotEmpty ? media[0]['url']?.toString() : null;
    final title = listing['title']?.toString() ?? 'Untitled';
    final city = listing['city']?.toString() ?? '';
    final price = listing['price_daily'];
    final rating = listing['rating'] ?? 0;
    final featured = listing['is_featured'] == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image != null
                      ? Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                      : _placeholder(),
                  if (featured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    if (city.isNotEmpty)
                      Text(city, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    const Spacer(),
                    Row(
                      children: [
                        if (price != null)
                          Text(
                            '\$${price}/day',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                              fontSize: 13,
                            ),
                          ),
                        const Spacer(),
                        if ((rating as num) > 0) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          Text(' ${rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.primary.withOpacity(0.08),
      child: const Icon(Icons.image_outlined, color: AppTheme.primary, size: 36),
    );
  }
}
