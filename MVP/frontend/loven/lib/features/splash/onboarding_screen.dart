import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/res/theme/app_colors.dart';

/// Manages and displays the swipeable introduction pages for first-time users.
/// 
/// This screen handles the core presentation layout and logic of the onboarding flow,
/// dynamically inheriting typography and colors from the global design system.
/// It uses a PageView to seamlessly guide the user into the authentication phase.




// A simple model to hold the data for each onboarding page
// هذا الكلاس يضمن إن كل صفحة ترحيب عندها ثلاث عناصر، صورة، عنوان ، و وصف
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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Keeps track of the currently visible page index
  // متغير يتتبع رقم الصفحة الحالية اللي واقف عندها المستخدم
  int currentIndex = 0;

  // Controls the swipeable PageView
  // متغير يتحكم بحركة سحب الشاشة يمين ويسار 
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  // The content injected into the PageView
  List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/images/onboarding1.png',
      title: 'Now exploring art\nwill be easier',
      description: 'Discover unique artworks, join a vibrant artistic community. Start your creative adventure effortlessly with us.',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding4.png',
      title: 'Your Artistic Soulmate\nAwaits',
      description: 'Let us be your guide to the perfect masterpiece. Discover art tailored to your tastes for a truly rewarding experience.',
    ),
    OnboardingContent(
      image: 'assets/images/onboarding5.png',
      title: 'Start Your Adventure',
      description: 'Ready to embark on a quest for inspiration and beauty? Your adventure begins now. Let\'s go!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Extracting the theme to inherit global colors and typography automatically
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      // SafeArea ensures UI doesn't overlap with device notches or status bars
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  context.go('/', extra: {'isGuest': true});
                },
                child: const Text("Skip"),
              ),
            ),
            
            // The swipeable image and text area
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  // Update the state to trigger UI changes for dots and buttons
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
                        // The Artwork Image
                        Expanded(
                          child: Image.asset(
                            contents[i].image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title using the global titleLarge style (PT Serif)
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        // Description using global bodyMedium style (Almarai)
                        Text(
                          contents[i].description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Section: Dots, Continue Button, and Sign In
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  // Generate the dot indicators dynamically based on content length
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => buildDot(index, primaryColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Main Call-To-Action Button (inherits elevatedButtonTheme)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentIndex == contents.length - 1) {
                          // Navigate to signup on the last page
                          context.go('/auth');
                        } else {
                          // Animate to the next page smoothly
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        currentIndex == contents.length - 1 ? "Get Started" : "Continue",
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Secondary Sign In Button
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text("Sign in"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper widget to draw an animated dot indicator
  Widget buildDot(int index, Color primaryColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 8,
      width: currentIndex == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? primaryColor : primaryColor.withValues(alpha: 0.2),
      ),
    );
  }
}