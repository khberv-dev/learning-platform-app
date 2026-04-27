import 'package:student/core/domain/startup/model/survey_query_option.dart';

class SurveyQuery {
  final String title;
  final String description;
  final List<SurveyQueryOption> options;

  SurveyQuery({
    required this.title,
    required this.description,
    required this.options,
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
