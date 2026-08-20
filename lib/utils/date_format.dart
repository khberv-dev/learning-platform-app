import 'package:flutter/material.dart';

/// Locale-aware dates and times for the lesson and session cards.
///
/// Built on [MaterialLocalizations], which `flutter_localizations` already
/// loads for every locale the app supports. That keeps month names, hour
/// order and the 12- vs 24-hour choice out of our hands — the cards used to
/// carry their own English month tables and a hardcoded AM/PM.
String formatShortMonthDay(BuildContext context, DateTime dt) =>
    MaterialLocalizations.of(context).formatShortMonthDay(dt);

/// Follows the device's 12/24-hour setting, as the platform expects.
String formatTime(BuildContext context, DateTime dt) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// e.g. `Aug 18 · 3:30 PM` — for lessons close enough that the year is noise.
String formatMonthDayTime(BuildContext context, DateTime dt) =>
    '${formatShortMonthDay(context, dt)} · ${formatTime(context, dt)}';

/// Numeric and short, e.g. `8/18/2026`. Used where the year matters — a
/// recording can be from any year — and there is only a caption's worth of
/// room for it.
String formatShortDate(BuildContext context, DateTime dt) =>
    MaterialLocalizations.of(context).formatShortDate(dt);
