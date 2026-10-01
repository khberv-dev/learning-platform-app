import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

/// Day, abbreviated month and year with no weekday — `22-okt, 2026`,
/// `22 окт. 2026 г.`, `Oct 22, 2026` — for a date that stands on its own,
/// like when a subscription ends. [MaterialLocalizations.formatMediumDate]
/// would add a weekday and drop the year.
///
/// The date symbols are loaded by `GlobalMaterialLocalizations` for every
/// locale the app ships.
String formatMediumDate(BuildContext context, DateTime dt) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(dt);
