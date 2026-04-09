import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme.dart';


class ShimmerLoader extends StatelessWidget {
  final int itemCount;

  const ShimmerLoader({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.cardElevated,
      child: ListView.builder(
        itemCount: itemCount,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (_, __) => const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _box(width: 180, height: 16),
              const Spacer(),
              _box(width: 60, height: 22, radius: 6),
            ],
          ),
          const SizedBox(height: 10),
          _box(width: double.infinity, height: 12),
          const SizedBox(height: 6),
          _box(width: 220, height: 12),
          const SizedBox(height: 14),
          Row(
            children: [
              _box(width: 70, height: 22, radius: 6),
              const SizedBox(width: 8),
              _box(width: 90, height: 22, radius: 6),
              const Spacer(),
              _box(width: 80, height: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _box({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
