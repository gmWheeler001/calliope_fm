import 'dart:async';

import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    ref.read(currentStationProvider.notifier).state = station;
    context.push('/player');
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(stationsNotifierProvider);
    final featuredAsync = ref.watch(featuredStationProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverAppBar(
          pinned: true,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                // Gets the text closer in a simple way
                textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Calliope FM',
                // Gets the text closer in a simple way
                textHeightBehavior: TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          bottom: PreferredSize(
            // this can be measured better for future improvement.
            preferredSize: Size.fromHeight(106),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UiConstants.paddingFull,
                    UiConstants.seperatorFull,
                    UiConstants.paddingFull,
                    UiConstants.seperatorFull,
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
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
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

                // This space we will use as padding and an edge for the scrolling items
                SizedBox(height: UiConstants.seperatorFull),
              ],
            ),
          ),
        ),

        // Featured hero card
        SliverToBoxAdapter(
          child: featuredAsync.when(
            data: (station) => station != null
                ? FeaturedCard(
                    station: station,
                    onTap: () => _onStationTap(station),
                  )
                : const SizedBox.shrink(),
            loading: () => const SkeletonCard(height: 120),
            error: (e, _) => const SizedBox.shrink(),
          ),
        ),
        // Station list / skeleton / empty / error
        stationsAsync.when(
          data: (stations) {
            if (stations.isEmpty) {
              return SliverFillRemaining(
                child: _EmptyState(
                  onClear: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    ref.read(stationFiltersProvider.notifier).state =
                        const StationFilters(tags: []);
                  },
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == stations.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return StationCard(
                  station: stations[index],
                  onTap: () => _onStationTap(stations[index]),
                );
              }, childCount: stations.length + (_isFetchingNextPage ? 1 : 0)),
            );
          },
          loading: () => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, _) => const SkeletonCard(),
              childCount: 6,
            ),
          ),
          error: (e, _) => SliverFillRemaining(
            child: _ErrorState(
              error: e,
              onRetry: () => ref.invalidate(stationsNotifierProvider),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radio, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No stations found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search or clear filters',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onClear,
              child: const Text('Clear search & filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Could not load stations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
