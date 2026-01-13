import 'package:flutter/material.dart';

class BadgeModel {
  final String title;
  final String description;
  final IconData icon;
  final int requiredRecipes;

  BadgeModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredRecipes,
  });
}

class BadgesScreen extends StatelessWidget {
  final int recipeCount;

  BadgesScreen({super.key, required this.recipeCount});

  final List<BadgeModel> allBadges = [
    BadgeModel(
      title: "First Dish",
      description: "Post your 1st recipe",
      icon: Icons.restaurant_rounded,
      requiredRecipes: 1,
    ),
    BadgeModel(
      title: "Handful",
      description: "Post 5 recipes",
      icon: Icons.pan_tool_rounded,
      requiredRecipes: 5,
    ),
    BadgeModel(
      title: "Chef de Cuisine", //is French for "Head of the Kitchen."
      description: "Post 10 recipes",
      icon: Icons.outdoor_grill_rounded,
      requiredRecipes: 10,
    ),
    BadgeModel(
      title: "Kitchen King",
      description: "Post 25 recipes",
      icon: Icons.workspace_premium_rounded,
      requiredRecipes: 25,
    ),
    BadgeModel(
      title: "Master Chef",
      description: "Post 50 recipes",
      icon: Icons.auto_awesome_rounded,
      requiredRecipes: 50,
    ),
    BadgeModel(
      title: "Legend",
      description: "Post 100 recipes",
      icon: Icons.star_rounded,
      requiredRecipes: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "My Achievements",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: theme.iconTheme,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.82, // Adjusted slightly for the extra text
        ),
        itemCount: allBadges.length,
        itemBuilder: (context, index) {
          final badge = allBadges[index];
          final bool isUnlocked = recipeCount >= badge.requiredRecipes;

          return _buildBadgeCard(theme, badge, isUnlocked);
        },
      ),
    );
  }

  Widget _buildBadgeCard(ThemeData theme, BadgeModel badge, bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.dividerColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              size: 40,
              color: isUnlocked
                  ? theme.colorScheme.primary
                  : theme.hintColor.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? null : theme.hintColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              badge.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor.withOpacity(0.8),
              ),
            ),
          ),
          if (!isUnlocked)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${badge.requiredRecipes - recipeCount} left",
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
