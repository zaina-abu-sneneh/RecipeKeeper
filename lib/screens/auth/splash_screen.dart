import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recipe_keeper/screens/auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAppInitialization();
  }

  void _startAppInitialization() async {
    // await Firebase.initializeApp();
    // await Future.delayed(const Duration(seconds: 2)); // two seconds splash
    await Future.wait([
      Firebase.initializeApp(),
      Future.delayed(const Duration(seconds: 2)),
    ]); // Ensure at least 2 seconds splash

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        ), // to check if the user is logged in or not
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Background will automatically be pureWhite or backgroundDark
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(
                    isDark ? 0.15 : 0.1,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/chef-hat.png',
                    height: 80,
                    width: 80,
                    // if there is an error loading the image, show an icon
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: theme.colorScheme.primary,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Branding
              Text(
                'RecipeKeeper',
                style: theme.textTheme.headlineLarge?.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),

              Text(
                'Organize, Discover, Cook.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 64),

              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary, // Theme-aware color
                ),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*

                        ┌─────────────┐
                        │  Start App  │
                        └─────┬───────┘
                              │
                              ▼
                     ┌────────────────┐
                     │  AuthWrapper   │
                     │  Check if user │
                     │  is logged in  │
                     └─────┬──────────┘
                   Yes/│                  │No
                       ▼                  ▼
                ┌─────────────┐     ┌─────────────┐
                │ Dashboard   │     │ Choose screen│
                │             │     │ SignIn/Register │
                └─────────────┘     └─────┬───────┘
                                         │
                    ┌────────────────────┴───────────────────┐
                    │                                        │
              ┌─────────────┐                          ┌─────────────┐
              │   SignIn    │                          │  Register   │
              └─────┬───────┘                          └─────┬───────┘
                    │                                        │
            ┌───────────────┐                       ┌─────────────────┐
            │ Enter Email &  │                       │ Enter Full Name,│
            │ Password       │                       │ Email & Password│
            └─────┬─────────┘                       └─────┬────────────┘
                  │                                          │
          ┌──────────────┐                           ┌───────────────┐
          │ Press SignIn  │                           │ Press Sign Up │
          │ Button        │                           │ Button        │
          └─────┬────────┘                           └─────┬─────────┘
                │                                          │
        ┌───────────────┐                          ┌───────────────┐
        │ Form Valid?    │                          │ Form Valid?   │
        └─────┬─────────┘                          └─────┬─────────┘
      Yes│            │No                          Yes│           │No
          ▼            ▼                               ▼           ▼
 ┌────────────────┐ ┌───────────────┐       ┌────────────────┐    ┌───────────┐
 │ Call auth.signIn│ │ Show Form     │      │ Call auth.register│ │ Show Form │
 │                │ │ Validation    │       │ & save data in    │ │ Validation│
 │                │ │ Error         │       │ Firestore         │ │ Error     │
 └─────┬─────────┘ └───────────────┘       └─────┬────────────┘
       │                                         │
       ▼                                         ▼
 ┌───────────────┐                          ┌──────────────────┐
 │ Login Success? │                         │ Register Success?│
 └─────┬─────────┘                          └─────┬────────────┘
    Yes│       │No                             Yes│       │No
       ▼       ▼                                  ▼       ▼
┌───────────────┐ ┌────────────────┐       ┌───────────────┐ ┌───────────────┐
│ AuthWrapper   │ │ Show Error     │       │ AuthWrapper   │ │ Show Error     │
│ detects user  │ │ Dialog from    │       │ detects user  │ │ Dialog from    │
│ → navigate to │ │ auth           │       │ → navigate to │ │ auth           │
│ Dashboard     │ │                │       │ Dashboard     │ │                │
└───────────────┘ └────────────────┘       └───────────────┘ └───────────────┘
       │                                         │
       ▼                                         ▼
┌────────────────┐                          ┌────────────────┐
│  End Loading   │                          │  End Loading   │
└────────────────┘                          └────────────────┘


*/