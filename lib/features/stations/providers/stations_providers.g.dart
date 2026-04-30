// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stations_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$featuredStationHash() => r'f25673384d0aeadfcad989cd1a4c6a4503c5279c';

/// See also [featuredStation].
@ProviderFor(featuredStation)
final featuredStationProvider =
    AutoDisposeFutureProvider<RadioStation?>.internal(
      featuredStation,
      name: r'featuredStationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$featuredStationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeaturedStationRef = AutoDisposeFutureProviderRef<RadioStation?>;
String _$stationsNotifierHash() => r'2057eba55d0e553f2d42b29cd176a9011f1e246a';

/// See also [StationsNotifier].
@ProviderFor(StationsNotifier)
final stationsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      StationsNotifier,
      List<RadioStation>
    >.internal(
      StationsNotifier.new,
      name: r'stationsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$stationsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StationsNotifier = AutoDisposeAsyncNotifier<List<RadioStation>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
