import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_keeper/providers/auth_provider.dart';
import 'package:recipe_keeper/providers/nav_provider.dart';
import 'package:recipe_keeper/providers/theme_provider.dart';
import 'package:recipe_keeper/screens/auth/auth_wrapper.dart';
import 'package:recipe_keeper/screens/auth/sign_in.dart';
import 'package:recipe_keeper/screens/auth/sign_up.dart';
import 'package:recipe_keeper/screens/auth/splash_screen.dart';
import 'package:recipe_keeper/screens/core/dashboard_screen.dart';
import 'package:recipe_keeper/screens/core/favorites.dart';
import 'package:recipe_keeper/screens/core/home.dart';
import 'package:recipe_keeper/screens/profile/profile.dart';
import 'package:recipe_keeper/screens/profile/settings.dart';
import 'package:recipe_keeper/screens/profile/my_recipes_screen.dart';
import 'package:recipe_keeper/theme/dark_theme.dart';
import 'package:recipe_keeper/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: RecipeKeeperApp(),
    ),
  );
}

class RecipeKeeperApp extends StatelessWidget {
  const RecipeKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'RecipeKeeper',
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      darkTheme: myDarkTheme,
      themeMode:
          themeProvider.themeMode, // Use the theme mode from ThemeProvider
      home: SplashScreen(),
      routes: {
        '/authwrapper': (context) => const AuthWrapper(),
        '/splashscreen': (context) => SplashScreen(),
        '/loginscreen': (context) => SignIn(),
        '/registerscreen': (context) => RegisterScreen(),
        '/dashboardscreen': (context) => DashboardScreen(),
        '/profile': (context) => Profile(),
        '/settings': (context) => SettingsScreen(),
        '/home': (context) => HomeScreen(),
        '/myrecipes': (context) => MyRecipesScreen(),
        '/favorites': (context) => FavoritesScreen(),
      },
    );
  }
}
