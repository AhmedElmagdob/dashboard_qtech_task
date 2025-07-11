import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState extends Equatable {
  final bool isDark;
  const ThemeState({required this.isDark});

  @override
  List<Object?> get props => [isDark];
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _themeKey = 'isDarkTheme';
  ThemeCubit() : super(const ThemeState(isDark: false)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    emit(ThemeState(isDark: isDark));
  }

  Future<void> toggleTheme() async {
    final newIsDark = !state.isDark;
    emit(ThemeState(isDark: newIsDark));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newIsDark);
  }
} 