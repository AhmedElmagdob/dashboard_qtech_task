import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/files/presentation/bloc/file_state.dart';
import '../cubit/sidebar_cubit.dart';
import '../../../../features/files/presentation/bloc/file_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ProjectOverview extends StatelessWidget {
  final FileBloc fileBloc;
  const ProjectOverview({Key? key, required this.fileBloc}) : super(key: key);

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
        return _ProjectOverviewChartContent(
          largeFileCount: largeFileCount,
          smallFileCount: smallFileCount,
          fileState: fileState,
        );
      },
    );
  }
}

class _ProjectOverviewChartContent extends StatelessWidget {
  final int largeFileCount;
  final int smallFileCount;
  final FileState fileState;
  const _ProjectOverviewChartContent({
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
          const Text('Project Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: fileState is FileLoading
                ? Center(
                    child: SizedBox(

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
                    ),
                  )
                : Center(
                  child: SizedBox(
                      width: 160,
                      height: 170,
                    child: SfCircularChart(
                        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
                        series: <RadialBarSeries<_ChartData, String>>[
                          RadialBarSeries<_ChartData, String>(

                            dataSource: chartData,
                            xValueMapper: (_ChartData d, _) => d.label,
                            yValueMapper: (_ChartData d, _) => d.value,
                            pointColorMapper: (_ChartData d, _) => d.color,
                            dataLabelMapper: (_ChartData d, _) => '${d.value} file${d.value == 1 ? '' : 's'}',
                            dataLabelSettings: DataLabelSettings(
                              isVisible: !isEmpty,
                              textStyle: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                                    offset: Offset(0.5, 0.5),
                                  ),
                                ],
                              ),
                            ),
                            cornerStyle: CornerStyle.bothCurve,
                            // maximumValue: 200,
                            gap: '10%',
                            radius: '100%',
                            innerRadius: '70%',
                          ),
                        ],
                      ),
                  ),
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