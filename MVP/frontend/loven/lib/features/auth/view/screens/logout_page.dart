// import 'package:flutter/material.dart';
// import '../../../core/storage/token_storage.dart';
// import '../../welcome/welcome_screen.dart';

// class LogoutPage extends StatelessWidget {
//   const LogoutPage({super.key});

//   Future<void> _logout(BuildContext context) async {
//     await TokenStorage().clearToken();

//     if (!context.mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const WelcomeScreen(),
//       ),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Log out'),
//       content: const Text('Are you sure you want to log out?'),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () => _logout(context),
//           child: const Text('Log out'),
//         ),
//       ],
//     );
//   }
// }
