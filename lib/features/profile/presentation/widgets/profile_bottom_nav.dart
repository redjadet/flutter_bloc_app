import 'package:flutter/material.dart';

class ProfileBottomNav extends StatelessWidget {
  const ProfileBottomNav({super.key});

  @override
  Widget build(final BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double bottomPadding = mediaQuery.padding.bottom;
    final double screenWidth = mediaQuery.size.width;
    final bool isCompactWidth = screenWidth < 360;
    final double navHeight = isCompactWidth ? 70 : 83;
    final double actionSlotWidth = isCompactWidth ? 60 : 70;
    final double actionSlotHeight = isCompactWidth ? 36 : 40;
    final double addIconSize = isCompactWidth ? 20 : 24;

    return Container(
      height: navHeight + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, -0.5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SizedBox(
              height: navHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(
                    icon: Icons.home_outlined,
                    onTap: () {},
                  ),
                  _NavIcon(
                    icon: Icons.search,
                    onTap: () {},
                  ),
                  SizedBox(width: actionSlotWidth),
                  _NavIcon(
                    icon: Icons.chat_bubble_outline,
                    onTap: () {},
                  ),
                  _NavIcon(
                    icon: Icons.person_outline,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: isCompactWidth ? 7 : 9,
            child: Center(
              child: Container(
                width: actionSlotWidth,
                height: actionSlotHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF00D6),
                      Color(0xFFFF4D00),
                    ],
                    stops: [0.0858, 0.9142],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {},
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: addIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (bottomPadding > 0)
            Positioned(
              left: 120,
              right: 120,
              bottom: bottomPadding - 5,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 40,
    height: 40,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Icon(
          icon,
          color: Colors.black.withValues(alpha: 0.8),
          size: 24,
        ),
      ),
    ),
  );
}
