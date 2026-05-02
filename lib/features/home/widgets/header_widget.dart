import 'package:calliope_fm/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabController?.removeListener(_onTabChange);
    _tabController = DefaultTabController.of(context);
    _tabController?.addListener(_onTabChange);
  }

  void _onTabChange() => setState(() {});

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChange);
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static const _tabMeta = [
    (icon: Icons.radio_rounded, tooltip: 'Stations'),
    (icon: Icons.favorite_border_rounded, tooltip: 'Favourites'),
    (icon: Icons.history_rounded, tooltip: 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _tabController?.index ?? 0;
    final others = [0, 1, 2].where((i) => i != current).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiConstants.paddingFull),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // fine UI adjustment to make the layout feel like it can breathe
                SizedBox(height: 2),
                Text(
                  _greeting,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white30),
                ),
                Text(
                  'Calliope FM',
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: const FontWeight(600),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _animatedNavButton(context, others[0]),
              const SizedBox(width: UiConstants.seperatorFull),
              _animatedNavButton(context, others[1]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _animatedNavButton(BuildContext context, int tabIndex) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) {
        final scale = Tween<double>(begin: 0.7, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
        );
        return ScaleTransition(
          scale: scale,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _HeaderIconButton(
        key: ValueKey(tabIndex),
        icon: _tabMeta[tabIndex].icon,
        tooltip: _tabMeta[tabIndex].tooltip,
        onPressed: () => DefaultTabController.of(context).animateTo(tabIndex),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 22,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white38,
      ),
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}
