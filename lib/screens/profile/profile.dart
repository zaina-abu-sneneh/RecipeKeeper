import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_keeper/screens/profile/levels_screen.dart';
import 'package:recipe_keeper/theme/colors.dart';
import 'package:recipe_keeper/screens/profile/my_recipes_screen.dart';
import 'package:recipe_keeper/screens/profile/badges_screen.dart';
import 'package:recipe_keeper/widgets/username_text.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  // Level Calculation
  String _calculateLevel(int count) {
    if (count >= 20) return "Master Chef";
    if (count >= 10) return "Home Cook";
    if (count >= 1) return "Novice";
    return "Beginner";
  }

  // Badge Count Calculation
  int _calculateBadges(int count) {
    int badges = 0;
    if (count >= 1) badges++;
    if (count >= 5) badges++;
    if (count >= 10) badges++;
    if (count >= 25) badges++;
    if (count >= 50) badges++;
    if (count >= 100) badges++;
    return badges;
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context); // Access current theme

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(leading: BackButton()),
        body: const Center(child: Text("User not authenticated")),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('ownerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final int recipeCount = snapshot.hasData
              ? snapshot.data!.docs.length
              : 0;
          final int badgeCount = _calculateBadges(recipeCount);
          final String currentLevel = _calculateLevel(recipeCount);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildProfileHeader(theme, user, currentLevel),
                const SizedBox(height: 30),
                _buildStatsCard(
                  context,
                  theme,
                  recipeCount,
                  badgeCount,
                  currentLevel,
                ),
                const SizedBox(height: 30),
                _buildMenuSection(context, theme),
                const SizedBox(height: 30),
                _buildLogoutButton(context, theme),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, User user, String level) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: theme.dividerColor.withOpacity(0.1),
            child: Icon(Icons.person_rounded, size: 60, color: theme.hintColor),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserNameText(
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            // THE VERIFIED PERK LOGIC:
            ?level == "Master Chef"
                ? const Icon(
                    Icons.verified,
                    color: Colors.blue, // Traditional verified color
                    size: 20,
                  )
                : null,
          ],
        ),

        const SizedBox(height: 4),
        Text(
          user.email ?? "",
          style: TextStyle(color: theme.hintColor, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    ThemeData theme,
    int recipes,
    int badges,
    String level,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(theme, recipes.toString(), "Recipes", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyRecipesScreen()),
            );
          }),
          _buildVerticalDivider(theme),
          _buildStatItem(theme, badges.toString(), "Badges", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BadgesScreen(recipeCount: recipes),
              ),
            );
          }),
          _buildVerticalDivider(theme),
          _buildStatItem(theme, level, "Level", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LevelsScreen(recipeCount: recipes),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(ThemeData theme) =>
      Container(height: 30, width: 1, color: theme.dividerColor);

  Widget _buildMenuSection(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            theme,
            Icons.restaurant_menu_rounded,
            "My Kitchen",
            () {
              Navigator.pushNamed(context, '/myrecipes');
            },
          ),
          Divider(height: 1, indent: 50, color: theme.dividerColor),
          _buildMenuTile(theme, Icons.favorite_rounded, "Saved Recipes", () {
            Navigator.pushNamed(context, '/favorites');
          }),
          Divider(height: 1, indent: 50, color: theme.dividerColor),
          _buildMenuTile(theme, Icons.settings_rounded, "Account Settings", () {
            Navigator.pushNamed(context, '/settings');
          }),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    ThemeData theme,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: theme.hintColor,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return TextButton.icon(
      onPressed: () => _handleSignOut(context),
      icon: const Icon(
        Icons.logout_rounded,
        color: AppColors.rubyRed,
        size: 20,
      ),
      label: const Text(
        "Sign Out",
        style: TextStyle(color: AppColors.rubyRed, fontWeight: FontWeight.bold),
      ),
    );
  }
}
