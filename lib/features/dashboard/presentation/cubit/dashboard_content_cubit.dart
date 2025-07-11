import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

enum DashboardChartType { none, monthlyTarget, projectStatistics, projectOverview }

class DashboardContentState extends Equatable {
  final DashboardChartType chartType;
  const DashboardContentState({this.chartType = DashboardChartType.none});

  @override
  List<Object?> get props => [chartType];
}

class DashboardContentCubit extends Cubit<DashboardContentState> {
  DashboardContentCubit() : super(const DashboardContentState());

  void showChartDetail(DashboardChartType type) => emit(DashboardContentState(chartType: type));
  void showDashboard() => emit(const DashboardContentState(chartType: DashboardChartType.none));
} 