import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stations_providers.dart';

const _genres = [
  'news',
  'pop',
  'rock',
  'jazz',
  'classical',
  'country',
  'electronic',
  'hip-hop',
  'indie',
  'metal',
  'folk',
  'reggae',
  'soul',
  'blues',
  'talk',
];

class GenreChips extends ConsumerWidget {
  const GenreChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(stationFiltersProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = _genres[index];
          final selected = filters.tags.contains(genre);
          return FilterChip(
            label: Text(genre),
            selected: selected,
            onSelected: (isSelected) {
              final notifier = ref.read(stationFiltersProvider.notifier);
              if (isSelected) {
                notifier.state = filters.copyWith(tags: filters.tags + [genre]);
              } else {
                final newFilters = filters.tags;
                newFilters.remove(genre);
                notifier.state = filters.copyWith(tags: newFilters);
              }
            },
          );
        },
      ),
    );
  }
}
