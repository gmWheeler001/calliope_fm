import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stations_providers.dart';

class GenreChips extends ConsumerWidget {
  const GenreChips({super.key});

  String capitalizeFirstLetter(String word) {
    if (word.isEmpty || word.length < 2) {
      return word;
    }
    return word[0].toUpperCase() + word.substring(1);
  }

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

          return GestureDetector(
            onTap: () {
              final notifier = ref.read(stationFiltersProvider.notifier);

              if (genre == genres.first) {
                notifier.state = notifier.state.copyWith(clearTags: true);
                return;
              }

              var updatedFilters = [...filters.tags];

              if (updatedFilters.contains(genres.first)) {
                updatedFilters.remove(genres.first);
              }

              notifier.state = selected
                  ? filters.copyWith(
                      tags: updatedFilters.where((t) => t != genre).toList(),
                    )
                  : filters.copyWith(tags: [...updatedFilters, genre]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  UiConstants.buttonCornerRadius,
                ),
                gradient: selected ? UiConstants.purpleGradient : null,
                color: selected ? null : UiConstants.chipInactiveBackground,
                border: Border.all(color: UiConstants.chipBorder),
              ),
              child: Text(
                capitalizeFirstLetter(genre),
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.white : UiConstants.chipInactiveText,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
