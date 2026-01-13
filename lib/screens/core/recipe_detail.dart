import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_keeper/models/recipe.dart';
import 'package:recipe_keeper/screens/core/recipe_form_screen.dart';
import 'package:recipe_keeper/services/favorites_service.dart';
import 'package:recipe_keeper/theme/colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final String heroTag;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.heroTag,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

// TickerProviderStateMixin -> In this case, the TabController needs it to animate the sliding bar under "Ingredients" and "Instructions.
class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  //This object controls the movement between the "Ingredients" and "Instructions" tabs.
  late TabController _tabController;
  late List<bool> _done;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _done = List<bool>.filled(widget.recipe.instructions.length, false);
  }

  void _confirmDelete() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Delete Recipe?', style: theme.textTheme.titleLarge),
        content: const Text('This will remove the recipe permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(widget.recipe.id)
                  .delete();
              if (mounted) {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Return to home/list
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.rubyRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == widget.recipe.ownerId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      //Allows multiple scrollable areas to work together. It prevents the header from getting "stuck" while the list below scrolls.
      //To coordinate the scrolling of the "Header" (Image) and the "Body" (Tabs).
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          //A scrollable App Bar.
          SliverAppBar(
            expandedHeight: 300, // This is the starting height of the image.
            pinned:
                true, //the image disappears, but the top bar stays visible so the user doesn't lose the "Back" button, the "Edit" and "Delete" icons stay at the top

            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            // Icons are white to stand out against the image background
            iconTheme: const IconThemeData(color: Colors.white),
            actions: isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeFormScreen(
                            docId: widget.recipe.id,
                            initialData: {
                              'title': widget.recipe.title,
                              'imageUrl': widget.recipe.imageUrl,
                              'ingredients': widget.recipe.ingredients,
                              'instructions': widget.recipe.instructions,
                              'category': widget.recipe.category,
                              'isPublic': widget.recipe.isPublic,
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _confirmDelete,
                    ),
                  ]
                : null,
            //This is the container that stretches and shrinks.
            //It uses the background property to hold your recipe image.
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.heroTag,
                child: Image.network(widget.recipe.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          //this normal Column as a scrollable part of the header.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.category?.toUpperCase() ?? 'GENERAL',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.title,
                    style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.headlineLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // sticky headers -> is designed to stay once it reaches the top.
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.hintColor,
                indicatorColor: theme.colorScheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: "Ingredients"),
                  Tab(text: "Instructions"),
                ],
              ),
              theme.colorScheme.surface,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_buildIngredientsTab(theme), _buildInstructionsTab(theme)],
        ),
      ),
      floatingActionButton: _buildFavoriteButton(theme),
    );
  }

  Widget _buildFavoriteButton(ThemeData theme) {
    return StreamBuilder<Set<String>>(
      //It connects to your FavoritesService. Whenever a user favorites any recipe, this stream sends out a new list of IDs.
      stream: FavoritesService.instance.favoritesStream,
      builder: (context, snapshot) {
        final isFavorited = snapshot.data?.contains(widget.recipe.id) ?? false;
        //FloatingActionButton (FAB) has a built-in "Hero" animation by default.
        return FloatingActionButton(
          backgroundColor: theme.colorScheme.primaryContainer,
          //ensure that if you have multiple recipes open, Flutter doesn't get confused about which button belongs to which screen.
          heroTag:
              "fab-favorite-${widget.recipe.id}", // Added unique FAB tag as well
          onPressed: () async {
            HapticFeedback.mediumImpact(); // UX (User Experience) feature. It makes the phone give a physical "thump" (vibration) when tapped
            try {
              await FavoritesService.instance.toggleFavorite(widget.recipe.id);
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          },
          child: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited
                ? AppColors.rubyRed
                : theme.colorScheme.onPrimaryContainer,
          ),
        );
      },
    );
  }

  Widget _buildIngredientsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.recipe.ingredients.length,
      itemBuilder: (context, i) => ListTile(
        leading: Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
        title: Text(
          widget.recipe.ingredients[i],
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildInstructionsTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.recipe.instructions.length,
      itemBuilder: (context, i) => CheckboxListTile(
        activeColor: theme.colorScheme.primary,
        checkColor: Colors.white,
        value: _done[i],
        onChanged: (v) => setState(() => _done[i] = v!),
        title: Text(
          widget.recipe.instructions[i],
          style: theme.textTheme.bodyLarge?.copyWith(
            decoration: _done[i] ? TextDecoration.lineThrough : null,
            color: _done[i]
                ? theme.hintColor
                : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);
  final TabBar _tabBar;
  final Color backgroundColor;

  //Don't stretch or shrink this bar. Keep it at its natural height (usually around 46-50 pixels) at all times.
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  //Container: We wrap the _tabBar in a Container so we can give it that backgroundColor.
  //Without this, you might see the recipe text scrolling behind the tab buttons, which is hard to read.
  @override
  Widget build(BuildContext context, double offset, bool overlaps) =>
      Container(color: backgroundColor, child: _tabBar);

  //false: Since our TabBar doesn't change once the screen is loaded, we return false to save CPU power. It’s an optimization.
  @override
  bool shouldRebuild(_SliverAppBarDelegate old) => false;
}
