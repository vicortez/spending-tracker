import 'package:flutter/material.dart';
import 'package:spending_tracker/utils/spending_utils.dart';

class SectionedBarChart extends StatelessWidget {
  final List<CategorySpending> data;
  final double totalAmount;
  final double height;

  const SectionedBarChart({
    super.key,
    required this.data,
    required this.totalAmount,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || totalAmount <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(height / 4),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 4),
      child: SizedBox(
        height: height,
        child: Row(
          children: data.map((item) {
            // We use a large multiplier to convert double proportion to int flex
            final int flex = (item.totalAmount / totalAmount * 1000).round();
            if (flex == 0) return const SizedBox.shrink();

            return Flexible(
              flex: flex,
              child: Container(color: item.color, width: double.infinity),
            );
          }).toList(),
        ),
      ),
    );
  }
}
