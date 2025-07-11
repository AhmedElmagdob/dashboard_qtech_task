import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/files/presentation/bloc/file_state.dart';
import '../cubit/sidebar_cubit.dart';
import '../../../../features/files/presentation/bloc/file_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ProjectStatisticsChart extends StatelessWidget {
  const ProjectStatisticsChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, fileState) {
        int largeFileCount = 0;
        int smallFileCount = 0;
        if (fileState is FileLoaded) {
          largeFileCount = fileState.largeFileCount;
          smallFileCount = fileState.smallFileCount;
        }
        return _ProjectStatisticsChartContent(
          largeFileCount: largeFileCount,
          smallFileCount: smallFileCount,
          fileState: fileState,
        );
      },
    );
  }
}

class _ProjectStatisticsChartContent extends StatelessWidget {
  final int largeFileCount;
  final int smallFileCount;
  final FileState fileState;
  const _ProjectStatisticsChartContent({
    this.largeFileCount = 0,
    this.smallFileCount = 0,
    required this.fileState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.brightness == Brightness.dark
        ? const Color(0xFF23232A)
        : Colors.white;
    final orange = Colors.orange;
    final blue = Colors.blue;
    final gray = Colors.grey[300]!;
    final showGray = largeFileCount == 0 && smallFileCount == 0;
    final barData = [
      _BarData('>2MB', largeFileCount, showGray ? gray : orange),
      _BarData('<2MB', smallFileCount, showGray ? gray : blue),
    ];

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Project Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: fileState is FileLoading
                ? Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _shimmerBar(height: 40, width: 12),
                          const SizedBox(width: 8),
                          _shimmerBar(height: 60, width: 12),
                          const SizedBox(width: 8),
                          _shimmerBar(height: 30, width: 12),
                          const SizedBox(width: 8),
                          _shimmerBar(height: 70, width: 12),
                        ],
                      ),
                    ),
                  )
                : SfCartesianChart(
                    key: const ValueKey('project-statistics-chart'),
                    primaryXAxis: CategoryAxis(),
                    legend: const Legend(isVisible: false),
                    series: <ColumnSeries<_BarData, String>>[
                      ColumnSeries<_BarData, String>(
                        dataSource: barData,
                        xValueMapper: (_BarData d, _) => d.label,
                        yValueMapper: (_BarData d, _) => d.value,
                        pointColorMapper: (_BarData d, _) => d.color,
                        dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 14, color: Colors.white)),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showGray)
                ...[
                  Icon(Icons.bar_chart, color: gray),
                  const SizedBox(width: 4),
                  Text('No Data', style: TextStyle(color: gray, fontWeight: FontWeight.w600)),
                ]
              else ...[
                Icon(Icons.bar_chart, color: blue),
                const SizedBox(width: 4),
                Text('<2MB: $smallFileCount', style: TextStyle(color: blue, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Icon(Icons.bar_chart, color: orange),
                const SizedBox(width: 4),
                Text('>2MB: $largeFileCount', style: TextStyle(color: orange, fontWeight: FontWeight.w600)),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendIcon extends StatelessWidget {
  final Color color;
  const _LegendIcon({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

Widget _shimmerBar({required double height, required double width}) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class _BarData {
  final String label;
  final int value;
  final Color color;
  _BarData(this.label, this.value, this.color);
} 