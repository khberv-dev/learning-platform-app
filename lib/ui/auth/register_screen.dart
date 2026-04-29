import 'package:flutter/material.dart';
import 'package:student/app/theme/app_spacing.dart';
import 'package:student/utils/uz_phone_formatter.dart';

class RegisterScreen extends StatefulWidget {
  static const path = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool hasReferral = false;

  final formKey = GlobalKey<FormState>();
  final firstNameInputController = TextEditingController();
  final phoneNumberInputController = TextEditingController();
  final passwordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void onHasReferralClick() {
      setState(() {
        hasReferral = !hasReferral;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    "Create Account",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    "Join thousands of learners today",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  TextFormField(
                    decoration: InputDecoration(labelText: "First name"),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Phone number",
                      prefixText: '+998 ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [UzPhoneFormatter()],
                  ),
                  SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Password"),
                  ),
                  GestureDetector(
                    onTap: onHasReferralClick,
                    child: Row(
                      children: [
                        Checkbox(
                          value: hasReferral,
                          onChanged: (_) => onHasReferralClick(),
                        ),
                        Text("I have referral code"),
                      ],
                    ),
                  ),
                  hasReferral
                      ? TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Referral code",
                          ),
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {},
                      child: Text("Create Account"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameInputController.dispose();
    phoneNumberInputController.dispose();
    passwordInputController.dispose();

    super.dispose();
  }
}
