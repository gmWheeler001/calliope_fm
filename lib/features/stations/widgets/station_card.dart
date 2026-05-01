import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/core/widgets/radio_artwork_placeholder.dart';
import 'package:calliope_fm/core/widgets/station_badge.dart';
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
        style: const TextStyle(
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
        style: const TextStyle(fontSize: 14, color: Colors.white38),
      ),
      trailing: station.isUp ? const LiveBadge() : null,
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
                            // Supports transparent images of all types without
                            // falling back to grey
                            colors: [Color(0xFFCE93D8), Colors.white],
                          ),
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: url!,
                      fit: BoxFit.scaleDown,
                      placeholder: (context, _) =>
                          const RadioArtworkPlaceholder(),
                      errorWidget: (context, url, _) =>
                          const RadioArtworkPlaceholder(),
                    ),
                  ),
                ],
              )
            : const RadioArtworkPlaceholder(),
      ),
    );
  }
}