import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/app/theme/app_radius.dart';

final appThemeProvider = Provider((ref) => _baseTheme);

final _baseColorScheme =
    ColorScheme.fromSeed(
      seedColor: Color(0xff18c96a),
      brightness: Brightness.light,
    ).copyWith(
      primary: Color(0xff18c96a),
      onPrimary: Color(0xffffffff),
      surface: Color(0xffffffff),
      onSurface: Color(0xff111827),
      onSurfaceVariant: Color(0xff6b7280),
    );

final _progressIndicatorTheme = ProgressIndicatorThemeData(
  linearMinHeight: 6,
  borderRadius: BorderRadius.circular(AppRadius.round),
);

final _iconButtonTheme = IconButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(_baseColorScheme.surface),
  ),
);

final _filledButtonTheme = FilledButtonThemeData(
  style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size.fromHeight(56))),
);

final _inputDecorationTheme = InputDecorationThemeData(
  filled: true,
  fillColor: _baseColorScheme.onSurface.withAlpha(5),
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: _baseColorScheme.onSurfaceVariant.withAlpha(100),
      width: 2,
    ),
    borderRadius: BorderRadius.circular(AppRadius.lg),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: _baseColorScheme.onSurfaceVariant.withAlpha(100),
      width: 2,
    ),
    borderRadius: BorderRadius.circular(AppRadius.lg),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: _baseColorScheme.primary, width: 2),
    borderRadius: BorderRadius.circular(AppRadius.lg),
  ),
);

// App-wide rounded typeface. The design calls for SF Pro Rounded, but Apple's
// licence forbids embedding it in an app bundle (and it isn't installed on
// Android at all) — M PLUS Rounded 1c is an openly-licensed (OFL) look-alike
// used on both platforms instead. `.apply` rewrites every style's fontFamily
// while leaving size/weight/color alone, so this reaches text that reads
// `Theme.of(context).textTheme.*` and, via the ambient `DefaultTextStyle`
// every `MaterialApp` establishes, plain `Text('...', style: TextStyle(...))`
// calls elsewhere that don't set their own `fontFamily`.
const _fontFamily = 'MPLUSRounded1c';
final _baseTextTheme = ThemeData.light().textTheme.apply(
  fontFamily: _fontFamily,
);
final _basePrimaryTextTheme = ThemeData.light().primaryTextTheme.apply(
  fontFamily: _fontFamily,
);

final _baseTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Color(0xfff6f7fa),
  colorScheme: _baseColorScheme,
  textTheme: _baseTextTheme,
  primaryTextTheme: _basePrimaryTextTheme,
  progressIndicatorTheme: _progressIndicatorTheme,
  iconButtonTheme: _iconButtonTheme,
  filledButtonTheme: _filledButtonTheme,
  inputDecorationTheme: _inputDecorationTheme,
);
