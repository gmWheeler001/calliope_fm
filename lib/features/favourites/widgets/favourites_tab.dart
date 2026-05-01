import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
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
          return const EmptyState(
            icon: Icons.favorite_border,
            title: 'No favourites yet',
            subtitle: 'Tap the heart in the player to save a station',
          );
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
