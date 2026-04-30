import 'package:calliope_fm/features/stations/models/radio_station.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadioStation.fromJson', () {
    const fullJson = {
      'stationuuid': 'abc-123',
      'name': 'Test FM',
      'url': 'http://example.com/stream',
      'url_resolved': 'http://resolved.example.com/stream',
      'favicon': 'http://example.com/icon.png',
      'tags': 'pop,rock,indie',
      'country': 'United Kingdom',
      'countrycode': 'GB',
      'language': 'english',
      'votes': 42,
      'bitrate': 128,
      'lastcheckok': 1,
    };

    test('parses all fields correctly', () {
      final station = RadioStation.fromJson(fullJson);

      expect(station.stationUuid, 'abc-123');
      expect(station.name, 'Test FM');
      expect(station.streamUrl, 'http://resolved.example.com/stream');
      expect(station.faviconUrl, 'http://example.com/icon.png');
      expect(station.country, 'United Kingdom');
      expect(station.countryCode, 'GB');
      expect(station.language, 'english');
      expect(station.votes, 42);
      expect(station.bitrate, 128);
      expect(station.isUp, isTrue);
    });

    test('falls back to url when url_resolved is empty', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..['url_resolved'] = '';
      final station = RadioStation.fromJson(json);
      expect(station.streamUrl, 'http://example.com/stream');
    });

    test('returns null faviconUrl for empty favicon string', () {
      final json = Map<String, dynamic>.from(fullJson)..['favicon'] = '';
      final station = RadioStation.fromJson(json);
      expect(station.faviconUrl, isNull);
    });

    test('isUp is false when lastcheckok is 0', () {
      final json = Map<String, dynamic>.from(fullJson)..['lastcheckok'] = 0;
      final station = RadioStation.fromJson(json);
      expect(station.isUp, isFalse);
    });

    test('tagList splits comma-separated tags', () {
      final station = RadioStation.fromJson(fullJson);
      expect(station.tagList, ['pop', 'rock', 'indie']);
    });

    test('tagList is empty when tags is blank', () {
      final json = Map<String, dynamic>.from(fullJson)..['tags'] = '';
      final station = RadioStation.fromJson(json);
      expect(station.tagList, isEmpty);
    });

    test('handles missing optional fields gracefully', () {
      final station = RadioStation.fromJson({'stationuuid': 'x'});
      expect(station.name, '');
      expect(station.streamUrl, '');
      expect(station.faviconUrl, isNull);
      expect(station.votes, 0);
      expect(station.isUp, isFalse);
    });

    test('equality is based on stationUuid', () {
      final a = RadioStation.fromJson(fullJson);
      final b = RadioStation.fromJson(
        Map<String, dynamic>.from(fullJson)..['name'] = 'Different Name',
      );
      expect(a, equals(b));
    });
  });
}