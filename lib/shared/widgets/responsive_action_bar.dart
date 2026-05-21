import 'package:flutter/material.dart';

/// Shared action-row layouts for narrow widths.
///
/// **Static guard (`tool/check_row_action_overflow.sh`):**
/// - Call sites (e.g. auth, booking) use [ResponsiveDualCtaRow] / [ResponsiveActionOverflowBar]
///   so they often have **no** raw `Row(` + buttons — the script still scans them but only
///   flags standalone `Row(` (not `ResponsiveDualCtaRow(`).
/// - The wide-layout `Row` + [Expanded] for dual CTAs lives **here**; this file is in
///   PRIMARY_SCOPE so that canonical row cannot regress to unmitigated multi-button rows.
/// - Repo-wide `scope=all` still catches new raw `Row(` + multi-button patterns elsewhere.
///
/// **Widget proof:** `test/shared/widgets/responsive_dual_cta_row_layout_test.dart` and
/// feature tests (e.g. `logged_out_action_buttons_test.dart`).

/// Default horizontal gap for [OverflowBar] action groups (see [docs/design_system.md]).
const double kResponsiveActionBarSpacing = 12;

/// Intrinsic-width actions that may wrap on narrow widths ([OverflowBar]).
class ResponsiveActionOverflowBar extends StatelessWidget {
  const ResponsiveActionOverflowBar({
    required this.children,
    this.alignment = MainAxisAlignment.end,
    this.spacing = kResponsiveActionBarSpacing,
    this.overflowSpacing,
    super.key,
  });

  final List<Widget> children;
  final MainAxisAlignment alignment;
  final double spacing;
  final double? overflowSpacing;

  @override
  Widget build(final BuildContext context) {
    return OverflowBar(
      alignment: alignment,
      spacing: spacing,
      overflowSpacing: overflowSpacing ?? spacing,
      children: children,
    );
  }
}

/// Equal-width dual CTAs: [Row] + [Expanded] when available width is wide;
/// vertical stack below [stackBreakpoint].
class ResponsiveDualCtaRow extends StatelessWidget {
  const ResponsiveDualCtaRow({
    required this.start,
    required this.end,
    this.height,
    this.gap = kResponsiveActionBarSpacing,
    this.stackBreakpoint = 360,
    super.key,
  });

  final Widget start;
  final Widget end;
  final double? height;
  final double gap;
  final double stackBreakpoint;

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final double availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        if (availableWidth < stackBreakpoint) {
          final List<Widget> children = <Widget>[
            _maybeSized(height, start),
            SizedBox(height: gap),
            _maybeSized(height, end),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }
        return SizedBox(
          height: height,
          child: Row(
            children: <Widget>[
              Expanded(child: start),
              SizedBox(width: gap),
              Expanded(child: end),
            ],
          ),
        );
      },
    );
  }

  Widget _maybeSized(final double? height, final Widget child) {
    if (height == null) {
      return child;
    }
    return SizedBox(height: height, child: child);
  }
}
