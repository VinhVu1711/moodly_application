import 'package:flutter/material.dart';
import 'package:moodlyy_application/common/l10n_etx.dart';
import 'package:moodlyy_application/features/mood/presentation/mood_l10n.dart';
import 'package:provider/provider.dart';

import '../../vm/stats_vm.dart';
import '../../../mood/domain/mood.dart';

class MoodBarChart extends StatelessWidget {
  const MoodBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<StatsVM, Map<Emotion5, double>>(
      selector: (_, vm) => vm.percents,
      builder: (_, percents, __) {
        final order = [
          Emotion5.veryHappy,
          Emotion5.happy,
          Emotion5.neutral,
          Emotion5.sad,
          Emotion5.verySad,
        ];
        final topEntry = percents.entries.reduce(
          (a, b) => a.value >= b.value ? a : b,
        );

        final totalEntries = percents.values.fold(
          0.0,
          (sum, percent) => sum + percent,
        );
        final hasData = totalEntries > 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.mood_distribution_title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        hasData
                            ? context.l10n.most_common_with(topEntry.key.label)
                            : 'No data available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Enhanced mood items with animations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final e in order)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _EnhancedMoodPercentItem(
                          emotion: e,
                          percent: percents[e] ?? 0,
                          highlighted:
                              e == topEntry.key && (topEntry.value > 0),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Enhanced stacked bar with labels
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.overall_balance_title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (hasData)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: topEntry.key.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.dominated_by(topEntry.key.label),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: topEntry.key.color,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _EnhancedStackedPill(
                    percents: {
                      Emotion5.veryHappy: percents[Emotion5.veryHappy] ?? 0,
                      Emotion5.happy: percents[Emotion5.happy] ?? 0,
                      Emotion5.neutral: percents[Emotion5.neutral] ?? 0,
                      Emotion5.sad: percents[Emotion5.sad] ?? 0,
                      Emotion5.verySad: percents[Emotion5.verySad] ?? 0,
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EnhancedMoodPercentItem extends StatelessWidget {
  final Emotion5 emotion;
  final double percent;
  final bool highlighted;

  const _EnhancedMoodPercentItem({
    required this.emotion,
    required this.percent,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100);
    final c = emotion.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          // Enhanced avatar with glow effect for highlighted
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: highlighted
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: c.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: CircleAvatar(
              radius: highlighted ? 26 : 22,
              backgroundColor: c.withOpacity(highlighted ? 0.3 : 0.25),
              child: Container(
                padding: EdgeInsets.all(highlighted ? 8 : 6),
                child: Image.asset(
                  emotion.assetPath, // dùng assetPath từ model
                  fit: BoxFit.contain,
                  width: highlighted ? 32 : 28,
                  height: highlighted ? 32 : 28,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.sentiment_neutral,
                    color: c,
                    size: highlighted ? 24 : 20,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Enhanced percentage chip with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: highlighted ? 12 : 10,
              vertical: highlighted ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: highlighted
                  ? c.withOpacity(0.18)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: highlighted
                    ? c.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.3),
                width: highlighted ? 2 : 1,
              ),
            ),
            child: Text(
              '${p.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
                fontSize: highlighted ? 13 : 12,
                color: highlighted ? c : Colors.grey[700],
              ),
            ),
          ),

          // Mood label
          if (highlighted) ...[
            const SizedBox(height: 4),
            Text(
              emotion.l10n(context), // tái dùng label từ model
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EnhancedStackedPill extends StatelessWidget {
  final Map<Emotion5, double> percents;
  const _EnhancedStackedPill({required this.percents});

  @override
  Widget build(BuildContext context) {
    final keys = [
      Emotion5.veryHappy,
      Emotion5.happy,
      Emotion5.neutral,
      Emotion5.sad,
      Emotion5.verySad,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final children = <Widget>[];
        double offset = 0;

        for (final k in keys) {
          final p = (percents[k] ?? 0).clamp(0, 100) / 100.0;
          final segW = w * p;
          if (segW <= 0) continue;

          children.add(
            Positioned(
              left: offset,
              width: segW,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: k.color,
                  // Subtle gradient for depth
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      k.color,
                      k.color.withOpacity(0.8),
                    ],
                  ),
                ),
                child: segW > 30
                    ? Center(
                        child: Text(
                          '${(p * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          );
          offset += segW;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 28,
              color: Colors.grey[200],
              child: Stack(
                children: [
                  ...children,
                  // Subtle inner shadow for depth
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
