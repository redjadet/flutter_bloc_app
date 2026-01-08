import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_models.dart';
import 'package:flutter_bloc_app/features/library_demo/presentation/widgets/library_demo_theme.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class LibraryCategoryList extends StatelessWidget {
  const LibraryCategoryList({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final List<LibraryCategory> categories = [
      LibraryCategory(label: l10n.libraryDemoCategoryScapes),
      LibraryCategory(label: l10n.libraryDemoCategoryPacks),
    ];

    return Column(
      children: [
        for (int index = 0; index < categories.length; index += 1) ...[
          Container(
            padding: EdgeInsets.only(
              bottom: EpochSpacing.gapMedium,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: EpochColors.warmGrey.withValues(alpha: 0.35),
                ),
              ),
            ),
            child: _LibraryCategoryRow(category: categories[index]),
          ),
          if (index != categories.length - 1)
            SizedBox(height: EpochSpacing.gapSection),
        ],
      ],
    );
  }
}

class _LibraryCategoryRow extends StatelessWidget {
  const _LibraryCategoryRow({required this.category});

  final LibraryCategory category;

  @override
  Widget build(final BuildContext context) => InkWell(
    onTap: () {},
    child: Row(
      children: [
        Expanded(
          child: Text(
            category.label.toUpperCase(),
            style: EpochTextStyles.label(context),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            size: const Size(16, 16),
            painter: _CaretPainter(),
          ),
        ),
      ],
    ),
  );
}

class _CaretPainter extends CustomPainter {
  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()
      ..color = EpochColors.ash
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()
      ..moveTo(4.5, 1)
      ..lineTo(11.5, 8)
      ..lineTo(4.5, 15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) => false;
}
