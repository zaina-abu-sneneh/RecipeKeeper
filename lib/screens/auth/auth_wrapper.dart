import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_keeper/providers/nav_provider.dart';
import 'package:recipe_keeper/screens/core/dashboard_screen.dart';
import 'package:recipe_keeper/screens/auth/sign_in.dart';
import 'package:recipe_keeper/theme/colors.dart';
import 'package:recipe_keeper/providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // watch -> It makes this screen "stare" at the AuthProvider. If the Brain moves, this screen reacts.
    final auth = context.watch<AuthProvider>();

    // Firebase still checking auth state (app startup)
    if (auth.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
          ),
        ),
      );
    }

    // User is logged in
    if (auth.isAuthenticated) {
      // It tells Flutter: "Wait until the screen is finished drawing before you reset the navigation menu." (This prevents errors).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Unlike watch, this just sends a single command (like "Reset the menu") without staring.
        context.read<NavProvider>().resetIndex();
      });
      return const DashboardScreen();
    }

    // User is NOT logged in
    return const SignIn();
  }
}
/*
  Note:
  - This AuthWrapper listens to FirebaseAuth's authStateChanges stream.
  - It shows a loading indicator while waiting for auth state.
  - On error, it displays an error message.
  - If the user is signed in, it resets the navigation index and shows the DashboardScreen.
  - If not signed in, it shows the LoginScreen.

                  ┌───────────────┐
                  │ App Start     │
                  │ (AuthWrapper) │
                  └───────┬───────┘
                          │
                          ▼
            ┌────────────────────────────┐
            │ Is auth.isInitializing?    │
            └───────┬─────────────┬──────┘
                    │ YES         │ NO
                    ▼             ▼
       ┌──────────────────┐   ┌─────────────────────┐
       │ Show Circular     │   │ Is auth.isAuthenticated? │
       │ Progress Indicator│   └───────┬─────────────┬─────┘
       └──────────────────┘           │ YES         │ NO
                                      ▼             ▼
                      ┌──────────────────────────┐ ┌───────────────────┐
                      │ Run WidgetsBinding.addPost│ │ Navigate to       │
                      │ FrameCallback to reset   │ │ SignIn Screen     │
                      │ NavProvider index        │ └───────────────────┘
                      └─────────┬───────────────┘
                                │
                                ▼
                      ┌──────────────────────────┐
                      │ Navigate to DashboardScreen │
                      └──────────────────────────┘
*/