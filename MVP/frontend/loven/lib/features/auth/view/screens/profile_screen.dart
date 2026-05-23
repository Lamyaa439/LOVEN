import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loven/features/auth/view/widget/guest_settings_screen.dart';
import 'package:loven/features/auth/view/widget/registered_view.dart';
import '../../../../features/auth/controller/cubit/auth_cubit.dart';
import '../../../../features/auth/controller/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // If Guest, show the Guest UI directly
          if (state is AuthGuest) {
            return Scaffold(
              appBar: AppBar(title: Text("Settings")),
              body: GuestSettingsWidget(),
            );
          }
          // If logged in, show the actual profile content
          else if (state is AuthSuccess) {
            return RegisteredProfileView();
          }
          // Default: Loading or error
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
