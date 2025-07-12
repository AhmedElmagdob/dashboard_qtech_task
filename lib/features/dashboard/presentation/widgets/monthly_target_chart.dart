import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/files/presentation/bloc/file_state.dart';
import '../cubit/sidebar_cubit.dart';
import '../../../../features/files/presentation/bloc/file_bloc.dart';
import 'package:shimmer/shimmer.dart';

class MonthlyTargetChart extends StatelessWidget {
  final FileBloc fileBloc;
  const MonthlyTargetChart({Key? key, required this.fileBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileBloc, FileState>(
      bloc: fileBloc,
      builder: (context, fileState) {
        int largeFileCount = 0;
        int smallFileCount = 0;
        if (fileState is FileLoaded) {
          largeFileCount = fileState.largeFileCount;
          smallFileCount = fileState.smallFileCount;
        }
        return _MonthlyTargetChartContent(
          largeFileCount: largeFileCount,
          smallFileCount: smallFileCount,
          fileState: fileState,
        );
      },
    );
  }
}

class _MonthlyTargetChartContent extends StatelessWidget {
  final int largeFileCount;
  final int smallFileCount;
  final FileState fileState;
  const _MonthlyTargetChartContent({
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
    final data = <_ChartData>[];
    if (largeFileCount > 0) {
      data.add(_ChartData('>2MB', largeFileCount, orange));
    }
    if (smallFileCount > 0) {
      data.add(_ChartData(' 2MB', smallFileCount, blue));
    }
    final bool isEmpty = largeFileCount == 0 && smallFileCount == 0;
    final Color emptyColor = Colors.grey[300]!;
    // If empty, show a single full gray segment
    final chartData = isEmpty
        ? [
            _ChartData('No Data', 1, emptyColor),
          ]
        : data;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Target', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                : SfCircularChart(
                    legend: const Legend(isVisible: true, position: LegendPosition.bottom),
                    series: <DoughnutSeries<_ChartData, String>>[
                      DoughnutSeries<_ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (_ChartData d, _) => d.label,
                        yValueMapper: (_ChartData d, _) => d.value,
                        pointColorMapper: (_ChartData d, _) => d.color,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: !isEmpty,
                          textStyle: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        radius: '100%',
                        innerRadius: '50%',
                      ),
                    ],
                  ),
          ),
        ],
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


class _ChartData {
  final String label;
  final int value;
  final Color color;
  _ChartData(this.label, this.value, this.color);
}