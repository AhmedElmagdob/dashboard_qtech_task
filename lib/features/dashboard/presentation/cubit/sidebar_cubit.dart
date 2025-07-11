import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class SidebarState extends Equatable {
  final bool isOpen;
  final int selectedIndex;
  const SidebarState({required this.isOpen, required this.selectedIndex});

  @override
  List<Object?> get props => [isOpen, selectedIndex];
}

class SidebarCubit extends Cubit<SidebarState> {
  SidebarCubit() : super(const SidebarState(isOpen: true, selectedIndex: 0));

  void toggleSidebar() => emit(SidebarState(isOpen: !state.isOpen, selectedIndex: state.selectedIndex));
  void openSidebar() => emit(SidebarState(isOpen: true, selectedIndex: state.selectedIndex));
  void closeSidebar() => emit(SidebarState(isOpen: false, selectedIndex: state.selectedIndex));
  void selectIndex(int index) => emit(SidebarState(isOpen: state.isOpen, selectedIndex: index));
} 