import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../player/providers/player_provider.dart';
import '../../stations/models/radio_station.dart';
import '../../stations/widgets/station_card.dart';
import '../models/history_entry.dart';
import '../providers/history_provider.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  void _onStationTap(
    BuildContext context,
    WidgetRef ref,
    RadioStation station,
  ) {
    ref
        .read(playerNotifierProvider.notifier)
        .play(station, source: PlaySource.history);
    context.push('/player');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyNotifierProvider);

    return historyAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'No history yet',
            subtitle: 'Stations you play will appear here',
          );
        }
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _HistoryCard(
              entry: entry,
              onTap: () => _onStationTap(context, ref, entry.station),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const EmptyState(
        icon: Icons.history_toggle_off,
        title: 'Could not load history',
        subtitle: 'Check your connection and try again',
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry, required this.onTap});

  final HistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          StationCard(station: entry.station, onTap: onTap),
          Positioned(
            left: 16,
            right: 16,
            bottom: -1 * UiConstants.seperatorFull,
            child: Text(
              _formatTime(entry.lastListenedAt),
              style: TextStyle(fontSize: 12, color: Colors.white38),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    final timeStr = _time12h(dt);
    if (date == today) return 'Today · $timeStr';
    if (date == yesterday) return 'Yesterday · $timeStr';
    return '${_monthAbbr(dt.month)} ${dt.day} · $timeStr';
  }

  String _time12h(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String _monthAbbr(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}
