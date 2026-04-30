class RadioStation {
  const RadioStation({
    required this.stationUuid,
    required this.name,
    required this.streamUrl,
    this.faviconUrl,
    required this.tags,
    required this.country,
    required this.countryCode,
    required this.language,
    required this.votes,
    required this.bitrate,
    required this.isUp,
  });

  final String stationUuid;
  final String name;
  final String streamUrl;
  final String? faviconUrl;
  final String tags;
  final String country;
  final String countryCode;
  final String language;
  final int votes;
  final int bitrate;
  final bool isUp;

  List<String> get tagList => tags
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    final resolved = json['url_resolved'] as String? ?? '';
    return RadioStation(
      stationUuid: json['stationuuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      streamUrl: resolved.isNotEmpty ? resolved : json['url'] as String? ?? '',
      faviconUrl: _nullIfEmpty(json['favicon'] as String?),
      tags: json['tags'] as String? ?? '',
      country: json['country'] as String? ?? '',
      countryCode: json['countrycode'] as String? ?? '',
      language: json['language'] as String? ?? '',
      votes: json['votes'] as int? ?? 0,
      bitrate: json['bitrate'] as int? ?? 0,
      isUp: (json['lastcheckok'] as int? ?? 0) == 1,
    );
  }

  static String? _nullIfEmpty(String? s) =>
      (s == null || s.isEmpty) ? null : s;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadioStation && other.stationUuid == stationUuid;

  @override
  int get hashCode => stationUuid.hashCode;

  @override
  String toString() => 'RadioStation(uuid: $stationUuid, name: $name)';
}
