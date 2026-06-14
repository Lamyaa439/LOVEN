import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/storage/app_preferences.dart';
import 'package:loven/l10n/generated/app_localizations.dart';

/// First-launch onboarding carousel; marks completion before leaving the flow.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboardingAndGo(String location) async {
    await context.read<AppPreferences>().setOnboardingCompleted();
    if (!mounted) return;
    context.go(location);
  }

  List<OnboardingContent> get contents {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingContent(
        image: 'assets/images/onboarding1.png',
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      OnboardingContent(
        image: 'assets/images/onboarding4.png',
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      OnboardingContent(
        image: 'assets/images/onboarding5.png',
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppPreferences>();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                TextButton(
                  onPressed: () async {
                    final prefs = context.read<AppPreferences>();
                    final newCode = (prefs.languageCode == 'en') ? 'ar' : 'en';
                    await prefs.setLanguageCode(newCode);
                    setState(() {});
                  },
                  child: Text(
                      context.read<AppPreferences>().languageCode == 'en'
                          ? 'العربية'
                          : 'English'),
                ),
                TextButton(
                  onPressed: () => _completeOnboardingAndGo(AppRoutes.home),
                  child: Text(l10n.skip),
                )
              ]),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            contents[i].image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          contents[i].description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => buildDot(index, primaryColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentIndex == contents.length - 1) {
                          _completeOnboardingAndGo(AppRoutes.auth);
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        currentIndex == contents.length - 1
                            ? l10n.getStarted
                            : l10n.continueBtn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _completeOnboardingAndGo(AppRoutes.login),
                    child: Text(l10n.signIn),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, Color primaryColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index
            ? primaryColor
            : primaryColor.withValues(alpha: 0.2),
      ),
    );
  }
}
