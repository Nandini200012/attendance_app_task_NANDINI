import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'skeleton_loader.dart';

/// Full-page skeleton placeholder showing card and list shimmers during loading.
class PageSkeletonView extends StatelessWidget {
  final int listCount;
  final bool showHeader;
  final double firstCardHeight;
  final double secondCardHeight;

  const PageSkeletonView({
    super.key,
    this.listCount = 3,
    this.showHeader = true,
    this.firstCardHeight = 120.0,
    this.secondCardHeight = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenHorizontalPadding,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                const SkeletonLoader(
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(width: 120, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      SkeletonLoader(width: 180, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          SkeletonLoader(height: firstCardHeight),
          const SizedBox(height: 12),
          SkeletonLoader(height: secondCardHeight),
          const SizedBox(height: 16),
          const SkeletonLoader(width: 140, height: 14, borderRadius: 4),
          const SizedBox(height: 10),
          ...List.generate(
            listCount,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SkeletonLoader(height: 68, borderRadius: 12),
            ),
          ),
        ],
      ),
    );
  }
}

