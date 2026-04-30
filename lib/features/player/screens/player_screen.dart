import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => context.pop(),
        ),
        title: const Text('Now Playing'),
      ),
      body: const Center(child: Text('Player')),
    );
  }
}