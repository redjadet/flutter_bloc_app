import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class ChatBottomNavigationBar extends StatelessWidget {
  const ChatBottomNavigationBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: const SafeArea(
        child: _ChatBottomNavigationBarContent(),
      ),
    );
  }
}

class _ChatBottomNavigationBarContent extends StatelessWidget {
  const _ChatBottomNavigationBarContent();

  @override
  Widget build(final BuildContext context) => Padding(
    padding: context.pageHorizontalPaddingWithVertical(context.responsiveGap),
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
    final IconData icon, {
    required final bool isSelected,
    required final BuildContext context,
    final bool isPrimary = false,
  }) {
    final iconSize = context.responsiveIconSize;
    final containerSize = context.responsiveButtonHeight;
    final borderRadius = context.responsiveBorderRadius;

    final colors = Theme.of(context).colorScheme;
    if (isPrimary) {
      return SizedBox(
        width: containerSize,
        height: containerSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary,
                colors.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Center(
            child: Icon(
              icon,
              color: colors.onPrimary,
              size: iconSize,
            ),
          ),
        ),
      );
    }

    return Icon(
      icon,
      color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
      size: iconSize,
    );
  }
}
