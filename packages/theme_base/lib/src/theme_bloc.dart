import 'package:codebase/codebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'theme_bloc_data.dart';
part 'theme_event.dart';

final class ThemeBloc<T extends ThemeAppData> extends BaseAppBloc<ThemeEvent, T> {
  ThemeBloc({ThemeMode initialThemeMode = ThemeMode.system}) {
    on<ThemeModeUpdated>(_onThemeModeUpdated);
    on<ThemeToggled>(_onThemeToggled);

    add(ThemeModeUpdated(initialThemeMode));
  }

  Future<void> _onThemeModeUpdated(
    ThemeModeUpdated event,
    Emitter<BaseState<T>> emit,
  ) async {
    emit(SuccessState(data: ThemeAppData(themeMode: event.themeMode) as T));
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<BaseState<T>> emit,
  ) async {
    final activeTheme = switch (state) {
      SuccessState<T>(data: final ThemeAppData data) => data.themeMode,
      _ => ThemeMode.system,
    };

    final nextTheme = activeTheme == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    emit(SuccessState(data: ThemeAppData(themeMode: nextTheme) as T));
  }
}

