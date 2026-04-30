import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/radio_browser_api.dart';
import '../models/radio_station.dart';
import '../models/station_filters.dart';

part 'stations_providers.g.dart';

// ── Infrastructure ───────────────────────────────────────────────────────────

final radioBrowserApiProvider = Provider<RadioBrowserApi>((ref) {
  final api = RadioBrowserApi();
  ref.onDispose(api.dispose);
  return api;
});

// ── Current playing station ───────────────────────────────────────────────────

final currentStationProvider = StateProvider<RadioStation?>((ref) => null);

// ── Search & filter state ────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final stationFiltersProvider = StateProvider<StationFilters>(
  (ref) => const StationFilters(tags: []),
);

// ── Stations list (paginated) ────────────────────────────────────────────────

@riverpod
class StationsNotifier extends _$StationsNotifier {
  bool _hasMore = true;
  int _offset = 0;

  bool get hasMore => _hasMore;

  @override
  Future<List<RadioStation>> build() async {
    _hasMore = true;
    _offset = 0;

    final query = ref.watch(searchQueryProvider);
    final filters = ref.watch(stationFiltersProvider);
    final api = ref.read(radioBrowserApiProvider);

    final stations = await api.fetchStations(query: query, filters: filters);

    if (stations.length < AppConstants.stationsPageSize) _hasMore = false;
    _offset = stations.length;

    return stations;
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore) return;
    final current = state.valueOrNull;
    if (current == null) return;

    final query = ref.read(searchQueryProvider);
    final filters = ref.read(stationFiltersProvider);
    final api = ref.read(radioBrowserApiProvider);

    final next = await api.fetchStations(
      query: query,
      filters: filters,
      offset: _offset,
    );

    if (next.length < AppConstants.stationsPageSize) _hasMore = false;
    _offset += next.length;

    state = AsyncData([...current, ...next]);
  }
}

// ── Featured station (hero card) ─────────────────────────────────────────────

@riverpod
Future<RadioStation?> featuredStation(Ref ref) async {
  final api = ref.read(radioBrowserApiProvider);
  return api.fetchFeaturedStation();
}
