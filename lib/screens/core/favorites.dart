import 'package:flutter/material.dart';
import 'package:recipe_keeper/models/recipe.dart';
import 'package:recipe_keeper/services/favorites_service.dart';
import 'package:recipe_keeper/widgets/recipe_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: theme.iconTheme,
      ),
      body: StreamBuilder<Set<String>>(
        stream: FavoritesService.instance.favoritesStream,
        builder: (context, favSnapshot) {
          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          final favoriteIds = favSnapshot.data ?? {};

          if (favoriteIds.isEmpty) {
            return _buildEmptyState(theme);
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('recipes')
                .where(FieldPath.documentId, whereIn: favoriteIds.toList())
                .snapshots(),
            builder: (context, recipeSnapshot) {
              if (recipeSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Error loading favorites",
                    style: TextStyle(color: theme.hintColor),
                  ),
                );
              }
              if (!recipeSnapshot.hasData) return _buildEmptyState(theme);

              final docs = recipeSnapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final recipe = Recipe.fromFirestore(docs[index]);
                  return RecipeCard(recipe: recipe);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text(
            "Your cookbook is empty!",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Heart some recipes to save them here.",
            style: TextStyle(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
