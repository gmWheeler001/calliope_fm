import 'package:flutter/material.dart';

import '../widgets/all_stations_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: const TabBarView(
            children: [
              AllStationsTab(),
              Center(child: Text('No favourites yet')),
              Center(child: Text('No history yet')),
            ],
          ),
        ),
      ),
    );
  }
}
