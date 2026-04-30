import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/radio_station.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.onTap,
  });

  final RadioStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _StationAvatar(url: station.faviconUrl),
      title: Text(
        station.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (station.country.isNotEmpty) station.country,
          if (station.bitrate > 0) '${station.bitrate} kbps',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: station.isUp ? const _LiveBadge() : null,
      onTap: onTap,
    );
  }
}

class _StationAvatar extends StatelessWidget {
  const _StationAvatar({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorWidget: (context, url, _) => _fallback(),
        placeholder: (context, _) => Container(
          width: 48,
          height: 48,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.radio, color: Colors.grey),
      );
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}