import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/stations/models/radio_station.dart';
import '../../features/stations/models/station_filters.dart';
import '../constants/app_constants.dart';

class RadioBrowserApi {
  RadioBrowserApi() : _client = http.Client();

  final http.Client _client;

  static const _headers = {'User-Agent': 'calliope_fm/1.0'};

  Future<List<RadioStation>> fetchStations({
    String query = '',
    StationFilters? filters,
    int offset = 0,
    int limit = AppConstants.stationsPageSize,
  }) async {
    final f = filters ?? const StationFilters(tags: []);
    final params = <String, String>{
      'offset': '$offset',
      'limit': '$limit',
      'hidebroken': 'true',
      'order': f.order.apiValue,
    };

    if (query.isNotEmpty) params['name'] = query;
    if (f.tags.isNotEmpty) params['tag'] = f.tags.toString();
    if (f.country != null) params['country'] = f.country!;
    if (f.language != null) params['language'] = f.language!;
    if (f.minBitrate != null) params['bitrateMin'] = '${f.minBitrate}';

    final uri = Uri.parse(
      '${AppConstants.baseURL}/stations/search',
    ).replace(queryParameters: params);

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('fetchStations failed: ${response.statusCode}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => RadioStation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RadioStation?> fetchFeaturedStation() async {
    final uri = Uri.parse('${AppConstants.baseURL}/stations/topvote/1');
    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode != 200) return null;

    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) return null;
    return RadioStation.fromJson(list.first as Map<String, dynamic>);
  }

  Future<void> voteForStation(String stationUuid) async {
    final uri = Uri.parse('${AppConstants.baseURL}/vote/$stationUuid');
    await _client.get(uri, headers: _headers);
  }

  void dispose() => _client.close();
}
