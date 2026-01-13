import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recipe_keeper/models/recipe.dart';
import 'package:recipe_keeper/screens/core/recipe_detail.dart';
import 'package:recipe_keeper/services/favorites_service.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final String heroSuffix;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.heroSuffix = '', // Default to empty if not provided
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  //late means I am not giving this variable a value right now,
  //but I promise I will give it one inside initState before the app tries to use it.
  late final FavoritesService
  _favSvc; // A reference to database logic for favorites
  Set<String> _favorites =
      {}; // A local collection of recipe IDs the user has liked

  //This is the "Object" that represents the active connection. You need to store it in a variable so you can "kill" it later in the dispose method.
  StreamSubscription<Set<String>>?
  _sub; // A "listener" that stays open to watch for changes.

  //The card "subscribes" to a stream. If the user favorites this recipe from a different screen,
  //this card will automatically fill in the heart icon without the user needing to refresh the page.
  @override
  void initState() {
    super.initState();
    _favSvc = FavoritesService.instance;
    //Every time the "Radio Station" (Service) broadcasts a new list of favorites,
    //the code inside these curly braces { } runs immediately.
    _sub = _favSvc.favoritesStream.listen((s) {
      //It is true if the card is currently visible on the screen. It is a safety check.
      if (mounted) setState(() => _favorites = s);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    // If you don't cancel the subscription, the app will keep listening forever,
    // even if the user leaves the screen, which wastes battery and RAM (memory leak)
    super.dispose();
  } // Memory Management (NFR)

  bool get _isFavorited => _favorites.contains(widget.recipe.id);

  Future<void> _toggleFavorite() async {
    try {
      await _favSvc.toggleFavorite(widget.recipe.id);
    } on StateError catch (_) {
      _showSignInDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));
      }
    }
  }

  void _showSignInDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign in required', style: theme.textTheme.titleLarge),
        content: Text(
          'Save your favorite recipes to access them anytime!',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/loginscreen');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Create a unique hero tag using the ID and the suffix
    final String heroTag =
        'recipe-image-${widget.recipe.id}-${widget.heroSuffix}';

    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: isDark ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(
                    // because recipe in the top part of Recipe card we use widget as a bridge between them.
                    recipe: widget.recipe,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: heroTag, // Use the generated unique tag
                  child: SizedBox(
                    width: 110,
                    child: Image.network(
                      widget.recipe.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        child: Icon(Icons.broken_image, color: theme.hintColor),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.recipe.category?.toUpperCase() ??
                                    'RECIPE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: Icon(
                                _isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorited
                                    ? Colors.redAccent
                                    : theme.hintColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.recipe.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'View Recipe',
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
