import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

import '../models/radio_station.dart';

class StationCard extends StatelessWidget {
  const StationCard({super.key, required this.station, required this.onTap});

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
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        [
          if (station.country.isNotEmpty) station.country,
          if (station.bitrate > 0) '${station.bitrate} kbps',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14, color: Colors.white38),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius / 2),
      child: SizedBox.square(
        dimension: 48,
        child: url != null
            ? Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.7,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              // Different as we need to support transparent images of all types,
                              // and want to avoid using greys
                              Color(0xFFCE93D8),
                              Colors.white,
                            ],
                          ),
                          shape: BoxShape.rectangle, // Keeps aspect ratio
                        ),

                        padding: const EdgeInsets.all(
                          8,
                        ), // keeps spacing similar to IconButton feel
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: url!,
                      fit: BoxFit.scaleDown,
                      placeholder: (context, _) => _fallback(),
                      errorWidget: (context, url, _) => _fallback(),
                    ),
                  ),
                ],
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A148C), Color(0xFFCE93D8)],
      ),
      shape: BoxShape.rectangle,
    ),

    padding: const EdgeInsets.all(
      8,
    ), // keeps spacing similar to IconButton feel
    child: Icon(Icons.radio, size: 24, color: Colors.white),
  );
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 0.5,
        ),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.tealAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
