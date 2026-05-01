import 'package:calliope_fm/features/stations/providers/stations_providers.dart';

enum StationOrder {
  votes,
  clickCount,
  trendingValue,
  name;

  String get apiValue => switch (this) {
    StationOrder.votes => 'votes',
    StationOrder.clickCount => 'clickcount',
    StationOrder.trendingValue => 'clicktrend',
    StationOrder.name => 'name',
  };
}

class StationFilters {
  const StationFilters({
    required this.tags,
    this.country,
    this.language,
    this.minBitrate,
    this.order = StationOrder.clickCount,
  });

  final List<String> tags;
  final String? country;
  final String? language;
  final int? minBitrate;
  final StationOrder order;

  StationFilters copyWith({
    List<String>? tags,
    String? country,
    String? language,
    int? minBitrate,
    StationOrder? order,
    bool clearTags = false,
    bool clearCountry = false,
    bool clearLanguage = false,
    bool clearMinBitrate = false,
  }) {
    return StationFilters(
      tags: clearTags ? [genres.first] : tags ?? this.tags,
      country: clearCountry ? null : (country ?? this.country),
      language: clearLanguage ? null : (language ?? this.language),
      minBitrate: clearMinBitrate ? null : (minBitrate ?? this.minBitrate),
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StationFilters &&
      other.tags == tags &&
      other.country == country &&
      other.language == language &&
      other.minBitrate == minBitrate &&
      other.order == order;

  @override
  int get hashCode => Object.hash(tags, country, language, minBitrate, order);
}
