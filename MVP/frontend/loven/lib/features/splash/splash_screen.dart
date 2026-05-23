import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  late Animation<double>
      fadeAnimation;

  late Animation<double>
      scaleAnimation;

  bool _showWelcome = false;

  final Color primaryDeepPurple =
      const Color(0xFF2E3192);

  final Color secondaryPurple =
      const Color(0xFF662D91);

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    );

    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    scaleAnimation =
        Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve:
                Curves.easeOutBack,
          ),
        );

    controller.forward();

    _startWelcomePhase();
  }

  Future<void>
      _startWelcomePhase() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      _showWelcome = true;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  FadeTransition(
                    opacity:
                        fadeAnimation,
                    child:
                        ScaleTransition(
                      scale:
                          scaleAnimation,
                      child:
                          Image.asset(
                        'assets/images/loven-logo.png',
                        width: 180,
                        fit: BoxFit
                            .contain,
                      ),
                    ),
                  ),

                  AnimatedOpacity(
                    duration:
                        const Duration(
                      milliseconds:
                          800,
                    ),
                    opacity:
                        _showWelcome
                            ? 1.0
                            : 0.0,
                    child:
                        _buildWelcomeActions(),
                  ),

                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),

            if (_showWelcome)
              Positioned(
                bottom: 40,
                child:
                    FadeTransition(
                  opacity:
                      fadeAnimation,
                  child:
                      TextButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: Text(
                      "Browse as Guest",
                      style:
                          TextStyle(
                        color:
                            secondaryPurple
                                .withOpacity(
                          0.7,
                        ),
                        fontSize:
                            16,
                        decoration:
                            TextDecoration
                                .underline,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeActions() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const SizedBox(
            height: 20,
          ),

          Text(
            'A space for every creative soul',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color:
                  primaryDeepPurple,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            'Whatever your art, this is your space to sell, inspire, and be seen.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color:
                  secondaryPurple
                      .withOpacity(
                0.8,
              ),
            ),
          ),

          const SizedBox(
            height: 35,
          ),

          ElevatedButton(
            onPressed: () {
              context.push(
                '/login',
              );
            },
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  primaryDeepPurple,
              foregroundColor:
                  Colors.white,
              fixedSize:
                  const Size(
                260,
                55,
              ),
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          OutlinedButton(
            onPressed: () {
              context.push(
                '/auth',
              );
            },
            style:
                OutlinedButton.styleFrom(
              fixedSize:
                  const Size(
                260,
                55,
              ),
              side: BorderSide(
                color:
                    primaryDeepPurple,
                width: 1.5,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),
            ),
            child: Text(
              "Sign Up",
              style: TextStyle(
                color:
                    primaryDeepPurple,
                fontSize: 16,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}