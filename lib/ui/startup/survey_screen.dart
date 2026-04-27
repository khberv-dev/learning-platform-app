import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/core/domain/startup/model/survey_query.dart';
import 'package:student/core/domain/startup/model/survey_query_option.dart';
import 'package:student/ui/startup/skill_level_quiz_screen.dart';
import 'package:student/ui/startup/widget/survey_header.dart';
import 'package:student/ui/startup/widget/survey_query_select.dart';

class SurveyScreen extends StatefulWidget {
  static const path = '/survey';

  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int surveyProgress = 0;
  Map<SurveyQuery, int> surveySelectedOption = {};

  @override
  Widget build(BuildContext context) {
    final surveyQueries = [
      SurveyQuery(
        title: "Why are you\nlearning English?",
        description: "Choose all that apply",
        options: [
          SurveyQueryOption(
            text: "Career Growth",
            iconPath: 'assets/icons/briefcase.svg',
          ),
          SurveyQueryOption(
            text: "Travel & Adventure",
            iconPath: 'assets/icons/map.svg',
          ),
          SurveyQueryOption(
            text: "Academic Studies",
            iconPath: 'assets/icons/book.svg',
          ),
          SurveyQueryOption(
            text: "Personal Interest",
            iconPath: 'assets/icons/heart.svg',
          ),
          SurveyQueryOption(
            text: "Immigration",
            iconPath: 'assets/icons/globe.svg',
          ),
        ],
      ),
      SurveyQuery(
        title: "How much time can\nyou spend daily?",
        description: "We'll build a schedule that fits your lifestyle",
        options: [
          SurveyQueryOption(
            text: "5 minutes",
            iconPath: 'assets/icons/clock.svg',
          ),
          SurveyQueryOption(
            text: "15 minutes",
            iconPath: 'assets/icons/clock.svg',
          ),
          SurveyQueryOption(
            text: "30 minutes",
            iconPath: 'assets/icons/clock.svg',
          ),
          SurveyQueryOption(
            text: "1+ hour",
            iconPath: 'assets/icons/clock.svg',
          ),
        ],
      ),
    ];

    final activeSurveyQuery = surveyQueries[surveyProgress];

    void onBackClick() {
      if (surveyProgress == 0) {
        context.pop();
      } else {
        setState(() {
          surveyProgress--;
        });
      }
    }

    void onSurveyOptionClick(int index) {
      setState(() {
        surveySelectedOption = {
          ...surveySelectedOption,
          activeSurveyQuery: index,
        };
      });
    }

    void onNextClick() {
      if (surveyProgress < surveyQueries.length - 1) {
        setState(() {
          surveyProgress++;
        });
      } else {
        context.go(SkillLevelQuizScreen.path);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SurveyHeader(
              onBackClick: onBackClick,
              progressValue: surveyProgress + 1,
              progressMax: surveyQueries.length,
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeSurveyQuery.title,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        activeSurveyQuery.description,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      SurveyQuerySelect(
                        options: activeSurveyQuery.options,
                        current: surveySelectedOption[activeSurveyQuery],
                        onItemClick: onSurveyOptionClick,
                      ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              surveySelectedOption[activeSurveyQuery] != null
                              ? onNextClick
                              : null,
                          child: Text("Next"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
