import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../../stations/models/radio_station.dart';
import '../models/history_entry.dart';

part 'history_provider.g.dart';

@Riverpod(keepAlive: true)
class HistoryNotifier extends _$HistoryNotifier {
  @override
  Future<List<HistoryEntry>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(StorageKeys.playbackHistory) ?? [];
    return raw
        .map((s) => HistoryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(RadioStation station) async {
    final entry = HistoryEntry(station: station, lastListenedAt: DateTime.now());
    final current = state.valueOrNull ?? [];
    final updated = [
      entry,
      ...current.where((e) => e.station.stationUuid != station.stationUuid),
    ].take(AppConstants.historyMaxSize).toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> _persist(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.playbackHistory,
      entries.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
