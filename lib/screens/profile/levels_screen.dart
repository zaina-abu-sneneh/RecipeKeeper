import 'package:flutter/material.dart';

class LevelMilestone {
  final String title;
  final int minRecipes;
  final String perk;
  final IconData icon;

  LevelMilestone({
    required this.title,
    required this.minRecipes,
    required this.perk,
    required this.icon,
  });
}

class LevelsScreen extends StatelessWidget {
  final int recipeCount;

  LevelsScreen({super.key, required this.recipeCount});

  final List<LevelMilestone> milestones = [
    LevelMilestone(
      title: "Beginner",
      minRecipes: 0,
      perk: "Start your journey",
      icon: Icons.eco_rounded,
    ),
    LevelMilestone(
      title: "Novice",
      minRecipes: 1,
      perk: "Unlock Badge Gallery",
      icon: Icons.menu_book_rounded,
    ),
    LevelMilestone(
      title: "Home Cook",
      minRecipes: 10,
      perk: "Featured in community",
      icon: Icons.outdoor_grill_rounded,
    ),
    LevelMilestone(
      title: "Master Chef",
      minRecipes: 20,
      perk: "Verified Profile Badge",
      icon: Icons.stars_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Cooking Level",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCurrentLevelHeader(theme),
            const SizedBox(height: 30),
            _buildLevelTimeline(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLevelHeader(ThemeData theme) {
    // Find next milestone
    final nextMilestone = milestones.firstWhere(
      (m) => m.minRecipes > recipeCount,
      orElse: () => milestones.last,
    );

    // Avoid division by zero if recipeCount exceeds all milestones
    // Robustness (NFR)
    double progress = nextMilestone.minRecipes == 0
        ? 1.0
        : (recipeCount / nextMilestone.minRecipes).clamp(
            0.0,
            1.0,
          ); //  It ensures that the number never goes below 0.0 and never goes above 1.0.

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Overall Progress",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$recipeCount Recipes Shared",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            color: Colors.white,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 15),
          Text(
            recipeCount >= milestones.last.minRecipes
                ? "You've reached the top tier!"
                : "Only ${nextMilestone.minRecipes - recipeCount} more to reach ${nextMilestone.title}!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTimeline(ThemeData theme) {
    return Column(
      children: milestones.map((m) {
        bool isReached = recipeCount >= m.minRecipes;
        return Opacity(
          opacity: isReached ? 1.0 : 0.6,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isReached ? theme.colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              leading: CircleAvatar(
                backgroundColor: isReached
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                child: Icon(
                  m.icon,
                  color: isReached ? Colors.white : theme.hintColor,
                ),
              ),
              title: Text(
                m.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isReached
                      ? theme.textTheme.bodyLarge?.color
                      : theme.hintColor,
                ),
              ),
              subtitle: Text(
                m.perk,
                style: TextStyle(
                  color: isReached
                      ? theme.colorScheme.primary
                      : theme.hintColor,
                ),
              ),
              trailing: isReached
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : Text(
                      "${m.minRecipes} total",
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
