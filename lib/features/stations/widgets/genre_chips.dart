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
                gradient: selected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          UiConstants.darkPurple, // brighter purple
                          UiConstants.lightPurple, // pinkish purple
                        ],
                      )
                    : null,
                color: selected ? null : Colors.black.withAlpha(44),
                border: Border.all(color: Colors.white.withAlpha(17)),
              ),
              child: Text(
                genre,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white.withAlpha(200),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
