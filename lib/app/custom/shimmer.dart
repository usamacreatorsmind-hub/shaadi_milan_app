import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

//
// create shimmer for circle rectangle  and list shimmer

class ShimmerColors {
  static Color base(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.12);

  static Color highlight(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.04);

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
}

class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final ShapeBorder shapeBorder;

  const ShimmerLoading.rectangular({super.key, this.width, this.height})
    : shapeBorder = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );

  const ShimmerLoading.circular({super.key, this.width, this.height})
    : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ShimmerColors.base(context),
      highlightColor: ShimmerColors.highlight(context),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: ShimmerColors.surface(context),
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  const ListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(itemCount, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading.circular(width: 60, height: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerLoading.rectangular(
                        height: 16,
                        width: double.infinity,
                      ),
                      SizedBox(height: 8),
                      ShimmerLoading.rectangular(height: 12, width: 150),
                      SizedBox(height: 8),
                      ShimmerLoading.rectangular(height: 12, width: 100),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ShimmerColors.base(context),
      highlightColor: ShimmerColors.highlight(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ShimmerColors.surface(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerLine(context, width: double.infinity),
                  const SizedBox(height: 6),
                  shimmerLine(context, width: double.infinity),
                  const SizedBox(height: 6),
                  shimmerLine(context, width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shimmerLine(
    BuildContext context, {
    required double width,
    double height = 10,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ShimmerColors.surface(context),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class ShimmerProfileCard extends StatelessWidget {
  final double height;
  final double width;

  const ShimmerProfileCard({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ShimmerColors.base(context),
      highlightColor: ShimmerColors.highlight(context),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: ShimmerColors.surface(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ShimmerColors.surface(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(context, width * 0.6, 16),
                  const SizedBox(height: 8),
                  shimmerBox(context, width * 0.4, 14),
                  const SizedBox(height: 16),
                  shimmerBox(context, double.infinity, 40, radius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shimmerBox(
    BuildContext context,
    double width,
    double height, {
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ShimmerColors.surface(context),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
