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
    this.tag,
    this.country,
    this.language,
    this.minBitrate,
    this.order = StationOrder.clickCount,
  });

  final String? tag;
  final String? country;
  final String? language;
  final int? minBitrate;
  final StationOrder order;

  bool get hasFilters =>
      tag != null || country != null || language != null || minBitrate != null;

  StationFilters copyWith({
    String? tag,
    String? country,
    String? language,
    int? minBitrate,
    StationOrder? order,
    bool clearTag = false,
    bool clearCountry = false,
    bool clearLanguage = false,
    bool clearMinBitrate = false,
  }) {
    return StationFilters(
      tag: clearTag ? null : (tag ?? this.tag),
      country: clearCountry ? null : (country ?? this.country),
      language: clearLanguage ? null : (language ?? this.language),
      minBitrate: clearMinBitrate ? null : (minBitrate ?? this.minBitrate),
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StationFilters &&
      other.tag == tag &&
      other.country == country &&
      other.language == language &&
      other.minBitrate == minBitrate &&
      other.order == order;

  @override
  int get hashCode => Object.hash(tag, country, language, minBitrate, order);
}