import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SpendingDoughnutChart extends StatelessWidget {
  final Map<String, double> categoryBreakdown;

  const SpendingDoughnutChart({super.key, required this.categoryBreakdown});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final palette = [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];

    final entries = categoryBreakdown.entries.toList();
    final total = categoryBreakdown.values.fold(0.0, (sum, val) => sum + val);

    final sections = List.generate(entries.length, (index) {
      final entry = entries[index];
      final color = palette[index % palette.length];
      return PieChartSectionData(
        value: entry.value,
        color: color,
        radius: 28,
        showTitle: false,
      );
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'MONTHLY SPENDING BY CATEGORY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Text(
                'No expenditure recorded',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 36,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.map((e) {
                      final idx = entries.indexOf(e);
                      final col = palette[idx % palette.length];
                      final pct = total > 0
                          ? (e.value / total * 100).toStringAsFixed(1)
                          : '0';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: col,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                e.key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
