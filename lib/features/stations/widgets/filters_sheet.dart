import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/features/stations/providers/stations_providers.dart';
import 'package:calliope_fm/features/stations/widgets/genre_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FiltersSheet extends ConsumerWidget {
  const FiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: UiConstants.paddingFull,
          top: UiConstants.paddingFull + UiConstants.marginFull,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GenreChips(),
            TextButton(
              onPressed:
                  ref
                      .watch(
                        stationFiltersProvider.select((value) => value.tags),
                      )
                      .isNotEmpty
                  ? () {
                      final notifier = ref.read(
                        stationFiltersProvider.notifier,
                      );
                      notifier.state = notifier.state.copyWith(clearTags: true);
                    }
                  : null,
              child: Text('Clear all'),
            ),
          ],
        ),
      ),
    );
  }
}
