import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/widgets/gradient_blob.dart';
import 'package:flutter/material.dart';

import '../models/radio_station.dart';

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key, required this.station, required this.onTap});

  final RadioStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.all(UiConstants.paddingFull),
      child: ClipRRect(
        // Clips blur to rounded corners
        borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),

        child: AspectRatio(
          aspectRatio: 2.3,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
            child: Stack(
              children: [
                // Layer 0 — Some white to add contrast and make the card pop
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        UiConstants.cardCornerRadius,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),

                // Layer 1 — background blobs (paint first, sit behind everything)
                Positioned(
                  top: -1 * (width / 2.3),
                  right: -1 * (width / 2.6),
                  child: GradientBlob(color: Color(0xFF7c3aed), size: width),
                ),
                Positioned(
                  bottom: -1 * (width / 5),
                  left: -1 * (width / 5),
                  child: GradientBlob(
                    color: Color(0xFFec4899),
                    size: width * 0.6,
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Opacity(opacity: 0.03, child: _artwork()),
                ),

                // Layer 2, the application content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiConstants.paddingDouble,
                      vertical: UiConstants.paddingFull,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: UiConstants.seperatorFull),
                        const Text(
                          'FEATURED STATION',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: UiConstants.seperatorHalf),
                        Expanded(child: _info()),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: UiConstants.paddingFull,
                  right: UiConstants.paddingFull,
                  width: 50,
                  height: 50,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          UiConstants.darkPurple, // dark purple
                          UiConstants.lightPurple, // light purple
                        ],
                      ),
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _artwork() {
    if (station.faviconUrl == null) return _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.red,
        child: CachedNetworkImage(
          imageUrl: station.faviconUrl!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorWidget: (context, url, _) => _fallback(),
          placeholder: (context, _) =>
              Container(width: 80, height: 80, color: Colors.grey[200]),
        ),
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
    var extraInformation = '';
    if (station.country.isNotEmpty) {
      extraInformation = station.country;
    }
    if (station.tagList.isNotEmpty) {
      if (extraInformation.isNotEmpty) {
        extraInformation = '$extraInformation - ';
      }
      extraInformation = '$extraInformation${station.tagList[0]}';
    }
    if (extraInformation.isNotEmpty) {
      extraInformation = '$extraInformation - ';
    }
    extraInformation = '$extraInformation${station.bitrate}kbps';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          station.name,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight(600),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        Text(
          extraInformation,
          style: const TextStyle(fontSize: 12, color: Colors.white38),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),

        UnconstrainedBox(
          child: Container(
            margin: EdgeInsets.only(top: 6),
            padding: EdgeInsets.symmetric(
              horizontal: UiConstants.paddingHalf,
              vertical: UiConstants.paddingHalf / 2,
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thumb_up_rounded,
                  size: 12,
                  applyTextScaling: false,
                  color: Colors.white54,
                ),

                SizedBox(width: 4),

                Text(
                  station.votes.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.white54),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
