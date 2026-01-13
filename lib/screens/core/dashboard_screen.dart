import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_keeper/providers/nav_provider.dart';
import 'package:recipe_keeper/screens/core/favorites.dart';
import 'package:recipe_keeper/screens/core/home.dart';
import 'package:recipe_keeper/screens/core/recipe_form_screen.dart';
import 'package:recipe_keeper/screens/profile/settings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // (Scalability & Organization): Using a list to manage pages makes it easy to add, remove, or reorder tabs in the future.
  final List<Widget> _pages = [
    const HomeScreen(),
    const RecipeFormScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // using navProvider to get current index and set index on tap of BottomNavigationBar items
    // non-functional (Maintainability)
    final navProvider = Provider.of<NavProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody:
          true, // to make the screen not stop before the bottom navigation bar
      // indexed stack to maintain state of each page while switching tabs so it doesn't rebuild every time, it just shows/hides the pages
      // (Performance & Efficiency): Improves performance by preserving the state of each tab, reducing unnecessary rebuilds.
      body: IndexedStack(index: navProvider.currentIndex, children: _pages),

      // Customized Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black45 : Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        // ClipRRect is a widget that clips its child using a rounded rectangle.
        // The name "RRect" stands for "Rounded Rectangle"
        // (Usability & user Experience): Enhances visual appeal with rounded corners,
        // fixed to avoid shifting animation so the user can see all labels properly
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: theme.colorScheme.surface,
            currentIndex: navProvider.currentIndex,
            onTap: (index) {
              navProvider.setIndex(index);
            },
            // if there is more than 3 items, flutter defaults to shifting type
            // so we set it to fixed to show labels properly without shifting animation
            type: BottomNavigationBarType.fixed,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.unselectedWidgetColor.withOpacity(0.5),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            elevation: 0,
            // const means there is no need to rebuild this list every time
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
