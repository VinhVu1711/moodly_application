// import 'package:flutter/material.dart';
// import 'package:moodlyy_application/features/mood/domain/mood.dart';
// import 'package:moodlyy_application/features/stats/vm/stats_vm.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';


// // 1. Mood Streak Counter
// class MoodStreakCard extends StatelessWidget {
//   const MoodStreakCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<StatsVM, int>(
//       selector: (_, vm) => vm.currentStreak, // You'll need to add this to your VM
//       builder: (context, streak, _) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.purple.shade400, Colors.blue.shade400],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.purple.withOpacity(0.3),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.local_fire_department_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Current Streak',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     '$streak',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 6),
//                     child: Text(
//                       'days',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Keep logging your mood!',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.9),
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // 2. Weekly Mood Pattern (Heatmap style)
// class WeeklyMoodPattern extends StatelessWidget {
//   const WeeklyMoodPattern({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<StatsVM, Map<String, double>>(
//       selector: (_, vm) => vm.weeklyPattern, // You'll need to add this to your VM
//       builder: (context, weeklyData, _) {
//         final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_view_week_rounded,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Weekly Mood Pattern',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: weekdays.map((day) {
//                   final value = weeklyData[day] ?? 0.0;
//                   final emotion = _getEmotionFromValue(value);
                  
//                   return Column(
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: emotion.color.withOpacity(0.8),
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: emotion.color.withOpacity(0.3),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Center(
//                           child: Text(
//                             day.substring(0, 1),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         day,
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Emotion5 _getEmotionFromValue(double value) {
//     if (value >= 1.5) return Emotion5.veryHappy;
//     if (value >= 0.5) return Emotion5.happy;
//     if (value >= -0.5) return Emotion5.neutral;
//     if (value >= -1.5) return Emotion5.sad;
//     return Emotion5.verySad;
//   }
// }

// // 3. Mood Insights Card
// class MoodInsightsCard extends StatelessWidget {
//   const MoodInsightsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<StatsVM, MoodInsights>(
//       selector: (_, vm) => vm.insights, // You'll need to add this to your VM
//       builder: (context, insights, _) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: Colors.blue.withOpacity(0.2),
//               width: 1,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       Icons.lightbulb_outline_rounded,
//                       color: Colors.blue,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Mood Insights',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               _InsightItem(
//                 icon: Icons.trending_up_rounded,
//                 title: 'Best Day',
//                 subtitle: insights.bestDay,
//                 color: Colors.green,
//               ),
//               const SizedBox(height: 8),
//               _InsightItem(
//                 icon: Icons.schedule_rounded,
//                 title: 'Most Active Time',
//                 subtitle: insights.mostActiveTime,
//                 color: Colors.orange,
//               ),
//               const SizedBox(height: 8),
//               _InsightItem(
//                 icon: Icons.psychology_rounded,
//                 title: 'Mood Stability',
//                 subtitle: insights.stabilityScore,
//                 color: Colors.purple,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _InsightItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final Color color;

//   const _InsightItem({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 16,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 13,
//                 ),
//               ),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // 4. Monthly Comparison Chart
// class MonthlyComparisonChart extends StatelessWidget {
//   const MonthlyComparisonChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<StatsVM, List<MonthlyData>>(
//       selector: (_, vm) => vm.monthlyComparison, // You'll need to add this to your VM
//       builder: (context, monthlyData, _) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     Icons.compare_arrows_rounded,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Monthly Comparison',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 height: 200,
//                 child: BarChart(
//                   BarChartData(
//                     alignment: BarChartAlignment.spaceAround,
//                     maxY: 2,
//                     minY: -2,
//                     barTouchData: BarTouchData(enabled: true),
//                     titlesData: FlTitlesData(
//                       topTitles: const AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       rightTitles: const AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 30,
//                           getTitlesWidget: (value, _) {
//                             final emotion = _getEmotionFromValue(value);
//                             return Container(
//                               width: 20,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 color: emotion.color,
//                                 shape: BoxShape.circle,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, _) {
//                             final index = value.toInt();
//                             if (index < 0 || index >= monthlyData.length) {
//                               return const SizedBox();
//                             }
//                             return Text(
//                               monthlyData[index].monthShort,
//                               style: const TextStyle(fontSize: 11),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     barGroups: monthlyData.asMap().entries.map((entry) {
//                       final index = entry.key;
//                       final data = entry.value;
//                       return BarChartGroupData(
//                         x: index,
//                         barRods: [
//                           BarChartRodData(
//                             toY: data.averageMood,
//                             color: _getEmotionFromValue(data.averageMood).color,
//                             width: 16,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Emotion5 _getEmotionFromValue(double value) {
//     if (value >= 1.5) return Emotion5.veryHappy;
//     if (value >= 0.5) return Emotion5.happy;
//     if (value >= -0.5) return Emotion5.neutral;
//     if (value >= -1.5) return Emotion5.sad;
//     return Emotion5.verySad;
//   }
// }

// // 5. Quick Stats Summary Cards
// class QuickStatsRow extends StatelessWidget {
//   const QuickStatsRow({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Selector<StatsVM, QuickStats>(
//       selector: (_, vm) => vm.quickStats, // You'll need to add this to your VM
//       builder: (context, stats, _) {
//         return Row(
//           children: [
//             Expanded(
//               child: _QuickStatCard(
//                 icon: Icons.calendar_today_rounded,
//                 title: 'Total Days',
//                 value: '${stats.totalDays}',
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _QuickStatCard(
//                 icon: Icons.trending_up_rounded,
//                 title: 'Avg Mood',
//                 value: stats.averageMoodLabel,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _QuickStatCard(
//                 icon: Icons.emoji_emotions_rounded,
//                 title: 'Happy Days',
//                 value: '${stats.happyDays}',
//                 color: Colors.orange,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _QuickStatCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String value;
//   final Color color;

//   const _QuickStatCard({
//     required this.icon,
//     required this.title,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             color: color,
//             size: 20,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Data classes you'll need to add to your domain/models
// class MoodInsights {
//   final String bestDay;
//   final String mostActiveTime;
//   final String stabilityScore;

//   MoodInsights({
//     required this.bestDay,
//     required this.mostActiveTime,
//     required this.stabilityScore,
//   });
// }

// class MonthlyData {
//   final String monthShort;
//   final double averageMood;
//   final int totalEntries;

//   MonthlyData({
//     required this.monthShort,
//     required this.averageMood,
//     required this.totalEntries,
//   });
// }

// class QuickStats {
//   final int totalDays;
//   final String averageMoodLabel;
//   final int happyDays;

//   QuickStats({
//     required this.totalDays,
//     required this.averageMoodLabel,
//     required this.happyDays,
//   });
// }