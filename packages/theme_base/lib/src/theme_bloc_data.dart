part of 'theme_bloc.dart';

sealed class ThemeBlocData {
  const ThemeBlocData();
}

class ThemeAppData extends ThemeBlocData {
  const ThemeAppData({required this.themeMode});

  final ThemeMode themeMode;
}
