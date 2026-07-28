import 'package:student/core/startup/domain/model/survey_query_option.dart';

class SurveyQuery {
  final String title;

  /// Word or two under the title, e.g. "Choose all that apply".
  final String description;

  final List<SurveyQueryOption> options;

  /// Whether more than one option can be picked. Single-select queries clear
  /// the previous choice when a new one is tapped.
  final bool allowsMultiple;

  const SurveyQuery({
    required this.title,
    required this.description,
    required this.options,
    this.allowsMultiple = false,
  });

  @override
  int get hashCode => title.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! SurveyQuery) {
      return false;
    }

    return title == other.title;
  }
}
