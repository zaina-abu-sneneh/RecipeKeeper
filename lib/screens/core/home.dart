import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_keeper/models/recipe.dart';
import 'package:recipe_keeper/screens/core/search.dart';
import 'package:recipe_keeper/widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All'; // Tracks the active UI filter

  final List<String> _categories = [
    'All',
    'Appetizer',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Beverage',
  ];

  // NFR: Scalability => Server-side filtering reduces client workload
  Stream<QuerySnapshot> _getRecipeStream() {
    // 1. Base Filter: Security/Privacy requirement
    Query baseQuery = FirebaseFirestore.instance
        .collection('recipes')
        .where('isPublic', isEqualTo: true);
    // 2. Category Filter: Functional requirement
    if (_selectedCategory != 'All') {
      baseQuery = baseQuery.where('category', isEqualTo: _selectedCategory);
    }
    // 3. Default Sorting: Simplified logic (Removed redundant search range query)
    // NFR: Efficiency - Sorting and limiting results saves bandwidth
    return baseQuery
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }
  // Memory Management

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildCategoryList(theme),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // NFR: Availability - Real-time updates without reloading
                stream: _getRecipeStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // NFR: Robustness - Error handling for network/database issues
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No recipes found.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    // Important: padding for extendBody in Dashboard
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      // Converting raw Firestore Map data into a "Recipe" Object, hide the complexity of translating the data.
                      // NFR: Maintainability - Abstraction via Data Model
                      final recipe = Recipe.fromFirestore(docs[index]);
                      return RecipeCard(recipe: recipe, heroSuffix: 'home');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        10.0,
        16.0,
        8.0,
      ), //Left, Top, Right, Bottom
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RecipeKeeper",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                "What's on the menu today?",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme
                      .hintColor, // Automatically adapts brightness from themeData class
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  // It reduces the padding/margin inside a widget, By default, buttons are large to be "finger-friendly.
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 22,
                  ),
                  onPressed: () {
                    // built-in Flutter function that handles the entire search experience.
                    // It opens a full-screen search interface that overlays your current screen.
                    showSearch(
                      context: context,
                      delegate: RecipeSearchDelegate(),
                      /*
                      This delegate tells Flutter:
                      What to show in the search bar (the "Actions").
                      What to show when the user is typing (the "Suggestions").
                      What to show when the user presses Enter (the "Results").
                      */
                      // non functional requirement note: This improves Usability by following standard Android/iOS search patterns.
                    );
                  },
                ),
              ),
              // Makes a non-interactive widget clickable.
              // It has no visual look of its own.
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  // Represents a user or a profile picture
                  // Automatically clips images into a circle. It has a radius property and a backgroundColor for when an image is loading.
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 10),

            // A material-style "filter" button.
            // It has a selected (boolean) state. It automatically handles the "check" animation and background color changes when clicked.
            child: ChoiceChip(
              label: Text(cat),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? cat : _categories[0];
                  //when it selected in unselected case it will return to the All
                });
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.15),
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              pressElevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
