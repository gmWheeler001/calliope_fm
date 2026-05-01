import 'package:cached_network_image/cached_network_image.dart';
import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/core/widgets/gradient_blob.dart';
import 'package:flutter/material.dart';

import '../models/radio_station.dart';

class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key, required this.station, required this.onTap});

  final RadioStation station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(UiConstants.paddingFull),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
          child: Stack(
            children: [
              // Layer 0 — tinted background + border (sizes to Stack)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      UiConstants.cardCornerRadius,
                    ),
                    border: Border.all(
                      color: UiConstants.glassOutlineColor,
                      width: 0.5,
                    ),
                  ),
                ),
              ),

              // Layer 1 — background blobs
              Positioned(
                top: -1 * (width / 2.3),
                right: -1 * (width / 2.6),
                child: GradientBlob(color: UiConstants.violetBlob, size: width),
              ),
              Positioned(
                bottom: -1 * (width / 5),
                left: -1 * (width / 5),
                child: GradientBlob(
                  color: UiConstants.pinkBlob,
                  size: width * 0.6,
                ),
              ),

              // Layer 1.5 — watermark artwork
              Positioned.fill(child: Opacity(opacity: 0.03, child: _artwork())),

              // Layer 2 — content (non-positioned: drives the Stack's height)
              Padding(
                padding: const EdgeInsets.only(
                  right: UiConstants.paddingFull,
                  bottom: 15,
                  left: 22,
                  top: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: UiConstants.seperatorFull),
                    Text('FEATURED STATION', style: tt.titleSmall),
                    SizedBox(height: UiConstants.seperatorHalf),
                    _info(context),
                  ],
                ),
              ),
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

  Widget _info(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
          style: tt.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        Text(
          extraInformation,
          style: tt.bodySmall?.copyWith(color: Colors.white38),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: EdgeInsets.symmetric(
                horizontal: UiConstants.paddingHalf,
                vertical: UiConstants.paddingHalf / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(UiConstants.cardCornerRadius),
                border: Border.all(
                  color: UiConstants.glassOutlineColor,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.thumb_up_rounded,
                    size: 12,
                    applyTextScaling: false,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(station.votes.toString(), style: tt.bodySmall),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: UiConstants.purpleGradient,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}