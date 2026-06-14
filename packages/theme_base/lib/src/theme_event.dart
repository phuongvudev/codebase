
part of 'theme_bloc.dart';
sealed class ThemeEvent {
  const ThemeEvent();
}

final class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}

final class ThemeModeUpdated extends ThemeEvent {
  const ThemeModeUpdated(this.themeMode);

  final ThemeMode themeMode;
}

