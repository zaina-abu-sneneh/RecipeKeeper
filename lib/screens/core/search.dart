import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_keeper/models/recipe.dart';
import 'package:recipe_keeper/widgets/search_tile.dart';

class RecipeSearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => "Search recipe...";

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: Icon(Icons.clear_rounded, color: Theme.of(context).hintColor),
        onPressed: () => query =
            '', //query is a built-in variable from the SearchDelegate. When you set query = '', the text field clears.
      ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: Icon(
      Icons.arrow_back_ios_new_rounded,
      color: Theme.of(context).iconTheme.color,
    ),
    onPressed: () => close(
      context,
      null,
    ), // close(context, null) pops the search view off the navigation stack.
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchBody(context);

  Widget _buildSearchBody(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildCenteredMessage(
        context,
        Icons.search_rounded,
        "Search recipes by name",
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('isPublic', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        final results = snapshot.data!.docs
            .map((d) => Recipe.fromFirestore(d))
            .where((r) => r.title.toLowerCase().contains(query.toLowerCase()))
            .toList(); // here map convert to list of recipes by using Recipe.fromFireStore() then in the where we check if the title contains the query
        /*
            Why use client-side .contains() here instead of Firestore filtering?
            Answer: "Firestore doesn't support a true 'contains' keyword.
            By fetching the public recipes and filtering in Dart,
            I can provide a more powerful search that finds words anywhere in the title, 
            which is better for the user."
          */

        // This creates Empty States. It tells the user "No recipes found" or "Start searching" instead of showing a blank white screen.
        if (results.isEmpty) {
          return _buildCenteredMessage(
            context,
            Icons.search_off_rounded,
            'No recipes found for "$query"',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 8),
          itemCount: results.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 80),
          itemBuilder: (context, index) => SearchTile(recipe: results[index]),
        );
      },
    );
  }

  Widget _buildCenteredMessage(
    BuildContext context,
    IconData icon,
    String text,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: theme.hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
