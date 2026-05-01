import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/features/home/widgets/header_widget.dart';
import 'package:calliope_fm/core/widgets/gradient_blob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../favourites/widgets/favourites_tab.dart';
import '../../history/widgets/history_tab.dart';
import '../../player/widgets/mini_player.dart';
import '../../stations/widgets/all_stations_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Android 13+ requires POST_NOTIFICATIONS at runtime for media notifications.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Permission.notification.request();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return AnnotatedRegion(
      // Set the status bar to white
      value: SystemUiOverlayStyle.light,
      // Set the keys to close if you tap anywhere on the app that isnt the search
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Layer 1 — background blobs (paint first, sit behind everything)
              Positioned(
                top: -1 * (height / 8),
                right: -1 * (height / 8),
                child: GradientBlob(color: Color(0xFF7c3aed), size: height / 2),
              ),
              Positioned(
                bottom: height / 8,
                left: -1 * ((height / 3) / 2),
                child: GradientBlob(color: Color(0xFFec4899), size: height / 3),
              ),

              // Layer two, the application content
              Positioned.fill(
                bottom: 0,
                child: DefaultTabController(
                  length: 3,
                  child: SafeArea(
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HeaderWidget(),
                          Expanded(
                            child: ShaderMask(
                              shaderCallback: (Rect rect) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.white],
                                  stops: [0.8, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstOut,

                              child: const TabBarView(
                                children: [
                                  AllStationsTab(),
                                  FavouritesTab(),
                                  HistoryTab(),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: UiConstants.seperatorFull),
                          const MiniPlayer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
