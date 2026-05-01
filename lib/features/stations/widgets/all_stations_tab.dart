import 'dart:async';

import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../player/providers/player_provider.dart';
import '../models/radio_station.dart';
import '../models/station_filters.dart';
import '../providers/stations_providers.dart';
import 'featured_card.dart';
import 'genre_chips.dart';
import 'skeleton_card.dart';
import 'station_card.dart';

class AllStationsTab extends ConsumerStatefulWidget {
  const AllStationsTab({super.key});

  @override
  ConsumerState<AllStationsTab> createState() => _AllStationsTabState();
}

class _AllStationsTabState extends ConsumerState<AllStationsTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  bool _isFetchingNextPage = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isFetchingNextPage) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 250) _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    final notifier = ref.read(stationsNotifierProvider.notifier);
    if (!notifier.hasMore) return;
    setState(() => _isFetchingNextPage = true);
    await notifier.fetchNextPage();
    if (mounted) setState(() => _isFetchingNextPage = false);
  }

  Future<void> _onRefresh() async {
    ref.invalidate(stationsNotifierProvider);
    ref.invalidate(featuredStationProvider);
    await ref.read(stationsNotifierProvider.future);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  void _onStationTap(RadioStation station) {
    ref
        .read(playerNotifierProvider.notifier)
        .play(station, source: PlaySource.stations);
    context.push('/player');
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsNotifierProvider);
    final featuredAsync = ref.watch(featuredStationProvider);

    return Column(
      children: [
        // Search input
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UiConstants.paddingFull,
            UiConstants.paddingFull,
            UiConstants.paddingFull,
            UiConstants.paddingFull,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Artists, genres, countries...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  UiConstants.buttonCornerRadius,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),

        // Genre chips
        GenreChips(),

        // Content
        Expanded(
          // Fade content out at the top, here to prevent a hard edge on scrolling upto the genre chips.
          // Bottom fade handled further into the widget tree.
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.transparent, Colors.white],
                //set stops as par your requirement
                stops: [0.96, 1.0], // 50% transparent, 50% white
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,

            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Featured hero card
                  SliverToBoxAdapter(
                    child: featuredAsync.when(
                      data: (station) => station != null
                          ? FeaturedCard(
                              station: station,
                              onTap: () => _onStationTap(station),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SkeletonCard(height: 150),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
                  ),

                  // Station list / skeleton / empty / error
                  stationsAsync.when(
                    data: (stations) {
                      if (stations.isEmpty) {
                        return SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.radio,
                            title: 'No stations found',
                            subtitle: 'Try a different search or clear filters',
                            action: ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).state = '';
                                ref.read(stationFiltersProvider.notifier).state =
                                    const StationFilters(tags: []);
                              },
                              child: const Text('Clear search & filters'),
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == stations.length) {
                              return const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return StationCard(
                              station: stations[index],
                              onTap: () => _onStationTap(stations[index]),
                            );
                          },
                          childCount:
                              stations.length + (_isFetchingNextPage ? 1 : 0),
                        ),
                      );
                    },
                    loading: () => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, _) => const SkeletonCard(),
                        childCount: 6,
                      ),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.wifi_off,
                        title: 'Could not load stations',
                        subtitle: 'Check your connection and try again',
                        action: ElevatedButton(
                          onPressed: () => ref.invalidate(stationsNotifierProvider),
                          child: const Text('Retry'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

