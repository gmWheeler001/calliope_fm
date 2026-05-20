// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerVolumeHash() => r'213a5ef25c909b8712ae5d1a08d16167e0ea4f24';

/// See also [PlayerVolume].
@ProviderFor(PlayerVolume)
final playerVolumeProvider =
    AutoDisposeNotifierProvider<PlayerVolume, double>.internal(
      PlayerVolume.new,
      name: r'playerVolumeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playerVolumeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlayerVolume = AutoDisposeNotifier<double>;
String _$playerNotifierHash() => r'64355ae31c6844a59d38d18e8ff91f3aa13bab19';

/// See also [PlayerNotifier].
@ProviderFor(PlayerNotifier)
final playerNotifierProvider =
    NotifierProvider<PlayerNotifier, RadioPlayerState>.internal(
      PlayerNotifier.new,
      name: r'playerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlayerNotifier = Notifier<RadioPlayerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
