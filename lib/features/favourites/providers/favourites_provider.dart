import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/storage_keys.dart';
import '../../stations/models/radio_station.dart';

part 'favourites_provider.g.dart';

@Riverpod(keepAlive: true)
class FavouritesNotifier extends _$FavouritesNotifier {
  @override
  Future<List<RadioStation>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(StorageKeys.favouriteStationIds) ?? [];
    return raw
        .map((s) => RadioStation.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggle(RadioStation station) async {
    final current = state.valueOrNull ?? [];
    final isFav = current.any((s) => s.stationUuid == station.stationUuid);
    final updated = isFav
        ? current.where((s) => s.stationUuid != station.stationUuid).toList()
        : [station, ...current];
    state = AsyncData(updated);
    await _persist(updated);
  }

  bool isFavourite(String stationUuid) =>
      state.valueOrNull?.any((s) => s.stationUuid == stationUuid) ?? false;

  Future<void> _persist(List<RadioStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.favouriteStationIds,
      stations.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
