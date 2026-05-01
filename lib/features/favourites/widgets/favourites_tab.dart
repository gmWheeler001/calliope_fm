import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../player/providers/player_provider.dart';
import '../../stations/models/radio_station.dart';
import '../../stations/widgets/station_card.dart';
import '../providers/favourites_provider.dart';

class FavouritesTab extends ConsumerWidget {
  const FavouritesTab({super.key});

  void _onStationTap(BuildContext context, WidgetRef ref, RadioStation station) {
    ref.read(playerNotifierProvider.notifier).play(
      station,
      source: PlaySource.favourites,
    );
    context.push('/player');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(favouritesNotifierProvider);

    return favouritesAsync.when(
      data: (stations) {
        if (stations.isEmpty) {
          return const _EmptyFavourites();
        }
        return ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) => StationCard(
            station: stations[index],
            onTap: () => _onStationTap(context, ref, stations[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  const _EmptyFavourites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            const Text(
              'No favourites yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart in the player to save a station',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
