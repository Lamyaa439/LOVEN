// import 'package:flutter/material.dart';
// import '../../../core/storage/token_storage.dart';
// import '../../splash/splash_screen.dart';
// import '../View/Screens/settings_screen.dart';
// import '../View/guest_settings_screen.dart';

// class HomeDrawer extends StatefulWidget {
//   final bool isGuest;
//   const HomeDrawer({super.key, this.isGuest = false});

//   @override
//   State<HomeDrawer> createState() => _HomeDrawerState();
// }

// class _HomeDrawerState extends State<HomeDrawer> {
//   // Toggle State: False = Buyer Mode, True = Artist Mode
//   bool isArtistMode = false;

//   // LOVEN Brand Colors
//   final Color primaryIndigo = const Color(0xFF2E3192);

//   Future<void> _logout(BuildContext context) async {
//     await TokenStorage().clearAccessToken();
//     if (!context.mounted) return;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const SplashScreen()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Drawer(
//       backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topRight: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           // 1. BRANDED HEADER
//           _buildHeader(isDarkMode),

//           const Divider(thickness: 0.5, indent: 20, endIndent: 20),

//           // 2. SCROLLABLE MENU ITEMS
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 // MAIN SHOPPING SECTION
//                 _buildSectionHeader(context, 'SHOPPING'),
//                 if (!widget.isGuest) ...[
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.shopping_cart_outlined,
//                     title: 'My Cart',
//                     trailing: _buildBadge('3'), //
//                     onTap: () {},
//                   ),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.favorite_border_rounded,
//                     title: 'Favorites',
//                     onTap: () {},
//                   ),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.inventory_2_outlined,
//                     title: 'My Orders',
//                     onTap: () {},
//                   ),
//                 ],
//                 // ARTIST SPECIFIC SECTION
//                 if (isArtistMode) ...[
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     child: Divider(thickness: 0.5),
//                   ),
//                   _buildSectionHeader(context, 'ARTIST STUDIO'),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.brush_outlined,
//                     title: 'My Workshops',
//                     onTap: () {},
//                   ),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.analytics_outlined,
//                     title: 'Sales Dashboard',
//                     onTap: () {},
//                   ),
//                 ],

//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: Divider(thickness: 0.5),
//                 ),

//                 // ACCOUNT & SUPPORT
//                 _buildSectionHeader(context, 'ACCOUNT'),
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.settings_outlined,
//                   title: 'Settings',
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => widget.isGuest
//                               ? const GuestSettingsScreen()
//                               : const SettingsScreen()),
//                     );
//                   },
//                 ),

//                 _buildSectionHeader(context, 'SUPPORT'),
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.auto_awesome_outlined,
//                   title: 'AI Assistant',
//                   onTap: () {},
//                 ),
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.chat_bubble_outline_rounded,
//                   title: 'Feedback & Suggestions',
//                   onTap: () {},
//                 ),
//                 _buildMenuItem(
//                   context,
//                   icon: Icons.flag_outlined,
//                   title: 'Report Issue',
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),

//           // 3. LOGOUT SECTION
//           const Divider(thickness: 0.5, indent: 20, endIndent: 20),
//           if (widget.isGuest)
//             _buildMenuItem(
//               context,
//               icon: Icons.login_rounded,
//               title: 'Login / Sign Up',
//               iconColor: primaryIndigo,
//               textColor: primaryIndigo,
//               onTap: () {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const SplashScreen(),
//                   ),
//                   (route) => false,
//                 );
//               },
//             )
//           else
//             _buildMenuItem(
//               context,
//               icon: Icons.logout_rounded,
//               title: 'Logout',
//               iconColor: Colors.redAccent,
//               textColor: Colors.redAccent,
//               onTap: () => _logout(context),
//             ),
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(bool isDarkMode) {
//     return Container(
//       padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   // Trigger profile view logic here
//                 },
//                 child: CircleAvatar(
//                   radius: 28,
//                   backgroundColor: primaryIndigo.withOpacity(0.1),
//                   child: Icon(
//                       widget.isGuest
//                           ? Icons.person_search
//                           : Icons.person_outline_rounded,
//                       color: primaryIndigo,
//                       size: 30),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.isGuest ? 'Guest User' : 'Creative Soul',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: isDarkMode ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   if (!widget.isGuest)
//                     Text(
//                       isArtistMode ? 'Artist Account' : 'Buyer Account',
//                       style: TextStyle(
//                         color: isDarkMode ? Colors.white70 : Colors.grey[600],
//                         fontSize: 13,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // MODE SWITCHER WITH CONTRAST FIX
//           if (!widget.isGuest)
//             Container(
//               height: 48,
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: isDarkMode ? Colors.white10 : Colors.grey[200],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildToggleButton(
//                         'Buyer', !isArtistMode, Icons.local_mall_outlined),
//                   ),
//                   Expanded(
//                     child: _buildToggleButton(
//                         'Artist', isArtistMode, Icons.auto_awesome_outlined),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleButton(String label, bool isActive, IconData icon) {
//     final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     // Contrast Adjustment Logic
//     Color getBgColor() {
//       if (!isActive) return Colors.transparent;
//       return Colors.white; // Use white pill for both modes to ensure visibility
//     }

//     Color getContentColor() {
//       if (!isActive) return Colors.grey;
//       return primaryIndigo; // Branded text on white background
//     }

//     return GestureDetector(
//       onTap: () => setState(() => isArtistMode = (label == 'Artist')),
//       child: Container(
//         decoration: BoxDecoration(
//           color: getBgColor(),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: isActive
//               ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
//               : [],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 18, color: getContentColor()),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                 color: getContentColor(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(BuildContext context, String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: Theme.of(context).hintColor,
//           fontSize: 11,
//           fontWeight: FontWeight.w800,
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(BuildContext context,
//       {required IconData icon,
//       required String title,
//       Widget? trailing,
//       VoidCallback? onTap,
//       Color? iconColor,
//       Color? textColor}) {
//     final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     return ListTile(
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 24),
//       visualDensity: const VisualDensity(vertical: -2),
//       leading: Icon(icon,
//           color: iconColor ??
//               (isDarkMode ? const Color(0xFF818CF8) : primaryIndigo),
//           size: 24),
//       title: Text(title,
//           style: TextStyle(
//               color: textColor ??
//                   (isDarkMode ? Colors.white70 : const Color(0xFF1E293B)),
//               fontSize: 15,
//               fontWeight: FontWeight.w500)),
//       trailing: trailing,
//     );
//   }

//   Widget _buildBadge(String count) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration:
//           const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//       child: Text(count,
//           style: const TextStyle(
//               color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
//     );
//   }
// }
