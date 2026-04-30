import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/radio_station.dart';

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.station,
    required this.onTap,
  });

  final RadioStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _artwork(),
              const SizedBox(width: 16),
              Expanded(child: _info()),
              const Icon(Icons.play_circle_filled, size: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artwork() {
    if (station.faviconUrl == null) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: station.faviconUrl!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorWidget: (context, url, _) => _fallback(),
        placeholder: (context, _) =>
            Container(width: 80, height: 80, color: Colors.grey[200]),
      ),
    );
  }

  Widget _fallback() => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.radio, size: 36, color: Colors.grey),
      );

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          station.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (station.tagList.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            station.tagList.take(3).join(', '),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}