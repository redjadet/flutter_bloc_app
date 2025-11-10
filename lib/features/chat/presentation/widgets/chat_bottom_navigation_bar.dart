import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChatBottomNavigationBar extends StatelessWidget {
  const ChatBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(
          color: Color(0xFFE5E5E5),
          width: 0.5,
        ),
      ),
    ),
    child: SafeArea(
      child: _ChatBottomNavigationBarContent(),
    ),
  );
}

class _ChatBottomNavigationBarContent extends StatelessWidget {
  const _ChatBottomNavigationBarContent();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: context.pageHorizontalPadding,
      vertical: context.responsiveGap,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          Icons.home_outlined,
          isSelected: false,
          context: context,
        ),
        _buildNavItem(
          Icons.search_outlined,
          isSelected: false,
          context: context,
        ),
        _buildNavItem(
          Icons.add,
          isSelected: true,
          isPrimary: true,
          context: context,
        ),
        _buildNavItem(
          Icons.chat_bubble_outline,
          isSelected: true,
          context: context,
        ),
        _buildNavItem(
          Icons.person_outline,
          isSelected: false,
          context: context,
        ),
      ],
    ),
  );

  Widget _buildNavItem(
    IconData icon, {
    required bool isSelected,
    required BuildContext context,
    bool isPrimary = false,
  }) {
    final iconSize = context.responsiveIconSize;
    final containerSize = context.responsiveButtonHeight;
    final borderRadius = context.responsiveBorderRadius;

    if (isPrimary) {
      return SizedBox(
        width: containerSize,
        height: containerSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ),
      );
    }

    return Icon(
      icon,
      color: isSelected ? Colors.black : Colors.grey,
      size: iconSize,
    );
  }
}
