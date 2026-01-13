import 'package:flutter/material.dart';
import 'package:recipe_keeper/models/recipe.dart';
import 'package:recipe_keeper/screens/core/recipe_detail.dart';

class SearchTile extends StatelessWidget {
  final Recipe recipe;

  const SearchTile({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define the unique tag for search results
    final String searchHeroTag = 'recipe-image-${recipe.id}-search';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: Hero(
        tag: searchHeroTag, // Updated to use the unique variable
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: recipe.imageUrl.isNotEmpty
              ? Image.network(
                  recipe.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(
                        theme,
                      ), // NFR: Robustness	Error Handling
                )
              : _buildPlaceholder(theme),
        ),
      ),
      title: Text(
        recipe.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        recipe.category?.toUpperCase() ?? 'GENERAL',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary.withOpacity(0.8),
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      // NFR : Accessibility	Visual Feedback: The trailing icon (arrow_forward_ios)
      // tells the user that this item is interactive and leads to a new page.
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.primary.withOpacity(0.5),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(
              recipe: recipe,
              heroTag: searchHeroTag, // FIXED: Now passing the required tag
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      color: theme.colorScheme.surfaceVariant,
      child: Icon(
        Icons.restaurant_menu,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/*
'Hero' widget is a specialized tool for creating shared element transitions, 
which are high-quality animations that move a visual piece (like a recipe image) smoothly from one screen to another to maintain the user's focus.
To perform this "hand-off," Flutter uses a Tag—a unique identifier or "handshake"—that must be identical on both the source and destination screens 
so the engine knows exactly which two elements to connect. By using a dynamic tag like recipe-image-${recipe.id}-search, you ensure each list item has its own "fingerprint,"
satisfying the Usability (NFR) requirement for visual continuity while preventing the app from crashing due to duplicate IDs.
*/
