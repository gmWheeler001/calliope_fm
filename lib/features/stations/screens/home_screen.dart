import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:calliope_fm/features/header/header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../favourites/widgets/favourites_tab.dart';
import '../../history/widgets/history_tab.dart';
import '../../player/widgets/mini_player.dart';
import '../widgets/all_stations_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                child: _GradientBlob(
                  color: Color(0xFF7c3aed),
                  size: height / 2,
                ),
              ),
              Positioned(
                bottom: height / 8,
                left: -1 * ((height / 3) / 2),
                child: _GradientBlob(
                  color: Color(0xFFec4899),
                  size: height / 3,
                ),
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
                                  //set stops as par your requirement
                                  stops: [
                                    0.8,
                                    1.0,
                                  ], // 50% transparent, 50% white
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

// The blob widget — a simple blurred circle
class _GradientBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GradientBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.33), Colors.transparent],
          stops: [0.0, 1.0],
        ),
      ),
    );
  }
}
