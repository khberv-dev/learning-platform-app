class SurveyQueryOption {
  final String text;

  /// Emoji shown before the label. The design uses full-colour glyphs, which
  /// the monochrome SVGs in assets/icons can't reproduce.
  final String emoji;

  const SurveyQueryOption({required this.text, required this.emoji});
}
