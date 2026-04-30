import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stations_providers.dart';

class GenreChips extends ConsumerWidget {
  const GenreChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(stationFiltersProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: UiConstants.paddingFull,
        ),
        itemCount: genres.length,
        separatorBuilder: (context, _) =>
            const SizedBox(width: UiConstants.seperatorFull),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final selected = filters.tags.contains(genre);
          return FilterChip(
            label: Text(genre),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UiConstants.buttonCornerRadius,
              ),
              side: BorderSide(color: Colors.black26, width: 1.0),
            ),
            selected: selected,
            onSelected: (isSelected) {
              final notifier = ref.read(stationFiltersProvider.notifier);

              if (genre == genres.first) {
                // All clears the list, as all genres will be allowed.
                notifier.state = notifier.state.copyWith(clearTags: true);
                return;
              }

              var updatedFilters = filters.tags;

              // Deselect all if the user selects something else
              if (updatedFilters.contains(genres.first)) {
                updatedFilters.remove(genres.first);
              }

              notifier.state = isSelected
                  ? filters.copyWith(tags: [...updatedFilters, genre])
                  : filters.copyWith(
                      tags: updatedFilters.where((t) => t != genre).toList(),
                    );
            },
          );
        },
      ),
    );
  }
}
