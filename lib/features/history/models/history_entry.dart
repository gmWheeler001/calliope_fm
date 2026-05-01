import '../../stations/models/radio_station.dart';

class HistoryEntry {
  const HistoryEntry({required this.station, required this.lastListenedAt});

  final RadioStation station;
  final DateTime lastListenedAt;

  Map<String, dynamic> toJson() => {
        ...station.toJson(),
        'last_listened_at': lastListenedAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        station: RadioStation.fromJson(json),
        lastListenedAt: DateTime.tryParse(
              json['last_listened_at'] as String? ?? '',
            ) ??
            DateTime.now(),
      );
}
