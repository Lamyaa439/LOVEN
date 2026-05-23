import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';
import '../../splash/splash_screen.dart';
import '../View/Screens/home_screen.dart';
import '../View/Screens/settings_screen.dart';
import '../View/guest_settings_screen.dart';

class DashboardPage extends StatefulWidget {
  final bool isGuest;
  const DashboardPage({super.key, this.isGuest = false});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  bool isArtistMode = false;
  final Color primaryIndigo = const Color(0xFF2E3192);

  // Helper to safely check features/tabs for guests
  void _onTabTapped(int index) {
    if (widget.isGuest && index > 0) {
      _showGuestLoginPrompt();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    await TokenStorage().clearAccessToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  void _showGuestLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content:
            const Text('Please sign in or register to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryIndigo),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            },
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Keep tabs preserved without rebuilding them
    final List<Widget> screens = [
      HomeScreen(isGuest: widget.isGuest),
      isArtistMode
          ? const Center(child: Text('Sales Dashboard Widget'))
          : const Center(child: Text('My Cart Widget')),
      widget.isGuest ? const GuestSettingsScreen() : const SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Screen content container
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Floating Toggle Mode Button at the Top Right of the dashboard
          if (!widget.isGuest)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode
                        ? Colors.white10
                        : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                  child: Row(
                    children: [
                      _buildHeaderModeTab('Buyer', !isArtistMode),
                      _buildHeaderModeTab('Artist', isArtistMode),
                    ],
                  ),
                ),
              ),
            ),

          // CUSTOM FLOATING BOTTOM NAVIGATION
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 24, top: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Main Navigation Pill Bar Container
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              ),
                            ],
                          ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavIcon(Icons.home_rounded, 0),
                            _buildNavIcon(
                              isArtistMode
                                  ? Icons.analytics_outlined
                                  : Icons.shopping_cart_outlined,
                              1,
                              badgeCount: isArtistMode ? null : '3',
                            ),
                            _buildNavIcon(Icons.person_rounded, 2),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Floating Support / Assistant Action Trigger
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          // Trigger your AI Assistant or Chat logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('AI Assistant Opening...')),
                          );
                        },
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E24)
                                : const Color(0xFFF1F1F5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: isDarkMode ? Colors.white : primaryIndigo,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {String? badgeCount}) {
    final bool isSelected = _currentIndex == index;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color iconColor() {
      if (isSelected) return primaryIndigo;
      return isDarkMode ? Colors.white60 : Colors.grey.shade600;
    }

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            size: 26,
            color: iconColor(),
          ),
          if (badgeCount != null)
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  badgeCount,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildHeaderModeTab(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (widget.isGuest) return;
        setState(() {
          isArtistMode = (label == 'Artist');
          // Reset view to main feed tab if content changes modes mid-stream
          _currentIndex = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 4)
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? primaryIndigo : Colors.grey,
          ),
        ),
      ),
    );
  }
}
