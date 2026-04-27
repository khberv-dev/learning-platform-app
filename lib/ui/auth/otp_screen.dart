import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/ui/shared/widget/otp_field.dart';

class OtpScreen extends ConsumerStatefulWidget {
  static const path = '/otp';

  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String? otp;

  @override
  Widget build(BuildContext context) {
    void onBackClick() {
      context.pop();
    }

    void onContinueClick() {}

    void onOtpComplete(String code) {
      setState(() {
        otp = code;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.xl),
              IconButton(
                onPressed: onBackClick,
                icon: SvgPicture.asset('assets/icons/arrow_left.svg'),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                "Verify Your\nPhone Number",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                "We sent code to +998 90 001 26 44",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              Center(child: OtpField(onCompleted: onOtpComplete)),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: otp != null ? onContinueClick : null,
                  child: Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
