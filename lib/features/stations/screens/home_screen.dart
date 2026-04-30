import 'package:flutter/material.dart';

// import '../widgets/all_stations_tab.dart';
// import '../widgets/filters_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calliope FM'),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Filters',
              onPressed: () => _showFilters(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Favourites'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Container(), // TODO: AllStationsTab(),
            Center(child: Text('No favourites yet')),
            Center(child: Text('No history yet')),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(), // TODO const FiltersSheet(),
    );
  }
}
