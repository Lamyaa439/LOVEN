import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:loven/core/router/app_routes.dart';
import 'package:loven/core/storage/app_preferences.dart';

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

  List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/images/onboarding1.png',
      title: 'Now exploring art\nwill be easier',
      description:
          'Discover unique artworks, join a vibrant artistic community. Start your creative adventure effortlessly with us.',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding4.png',
      title: 'Your Artistic Soulmate\nAwaits',
      description:
          'Let us be your guide to the perfect masterpiece. Discover art tailored to your tastes for a truly rewarding experience.',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding5.png',
      title: 'Start Your Adventure',
      description:
          'Ready to embark on a quest for inspiration and beauty? Your adventure begins now. Let\'s go!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _completeOnboardingAndGo(AppRoutes.home),
                child: const Text('Skip'),
              ),
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
                            ? 'Get Started'
                            : 'Continue',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        _completeOnboardingAndGo(AppRoutes.login),
                    child: const Text('Sign in'),
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
