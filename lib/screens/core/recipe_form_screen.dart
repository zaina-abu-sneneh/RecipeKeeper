import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:recipe_keeper/providers/nav_provider.dart';
import 'package:recipe_keeper/widgets/recipe_form_widgets.dart';

class RecipeFormScreen extends StatefulWidget {
  final String? docId; // If null = Add Mode, if not null = Edit Mode
  final Map<String, dynamic>? initialData;

  const RecipeFormScreen({super.key, this.docId, this.initialData});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _imageUrlController;

  // Form State
  late List<String> _ingredients;
  late List<String> _instructions;
  String? _selectedCategory;
  late bool _isPublic;
  bool _isSaving = false;

  // Helper getter to check mode
  bool get isEditing => widget.docId != null;

  final List<String> _categories = [
    'Appetizer',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Beverage',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill data if we are editing, otherwise start fresh
    _titleController = TextEditingController(
      text: widget.initialData?['title'] ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.initialData?['imageUrl'] ?? '',
    );
    _ingredients = List<String>.from(widget.initialData?['ingredients'] ?? []);
    _instructions = List<String>.from(
      widget.initialData?['instructions'] ?? [],
    );
    _selectedCategory = widget.initialData?['category'];
    _isPublic = widget.initialData?['isPublic'] ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // logic for the pop-up to add ingredients/instructions
  void _openAddItemModal({required String type}) {
    final tempController = TextEditingController();
    final theme = Theme.of(context); // Grabbing theme for the modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          // viewInsets -> top of keyboard
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add $type', style: theme.textTheme.titleLarge),
            const SizedBox(height: 15),
            TextField(
              controller: tempController,
              autofocus: true,
              style: theme.textTheme.bodyLarge,
              decoration: customInputDecoration(theme, "Enter $type..."),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                ),
                onPressed: () {
                  if (tempController.text.trim().isNotEmpty) {
                    setState(() {
                      type == 'ingredient'
                          ? _ingredients.add(tempController.text.trim())
                          : _instructions.add(tempController.text.trim());
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Add to List',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _imageUrlController.clear();
      _ingredients.clear();
      _instructions.clear();
      _selectedCategory = null;
      _isPublic = true;
      _isSaving = false;
    });
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty ||
        _instructions.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all sections')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = FirebaseAuth.instance.currentUser;

    final data = {
      'title': _titleController.text.trim(),
      'imageUrl': _imageUrlController.text.trim().isEmpty
          ? 'https://via.placeholder.com/300'
          : _imageUrlController.text.trim(),
      'ingredients': _ingredients,
      'instructions': _instructions,
      'category': _selectedCategory,
      'isPublic': _isPublic,
      'ownerId': user?.uid,
      if (!isEditing) 'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      if (isEditing) {
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.docId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('recipes').add(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Recipe Updated!' : 'Recipe Published!'),
          ),
        );
        if (isEditing) {
          Navigator.pop(context); // Go back to details or kitchen
        } else {
          _resetForm();
          Provider.of<NavProvider>(
            context,
            listen: false,
          ).setIndex(0); // Go home
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Recipe" : "New Recipe",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Card
              buildImagePreviewCard(
                theme: theme,
                imageUrl: _imageUrlController.text.trim(),
                controller: _imageUrlController,
              ),

              // 2. Recipe Name
              buildSectionLabel(theme, "Recipe Name"),
              TextFormField(
                controller: _titleController,
                style: theme.textTheme.bodyLarge,
                decoration: customInputDecoration(
                  theme,
                  "e.g. Grandma's Pasta",
                ),
                validator: (v) => v!.isEmpty ? 'Title required' : null,
              ),

              // 3. Category
              buildSectionLabel(theme, 'Category'),
              buildCategorySelector(
                theme: theme,
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelected: (cat) => setState(() => _selectedCategory = cat),
              ),

              // 4. Ingredients (Using a helper method below)
              _buildListSection(
                theme,
                "Ingredients",
                _ingredients,
                'ingredient',
              ),

              // 5. Instructions
              _buildListSection(
                theme,
                "Instructions",
                _instructions,
                'instruction',
              ),

              const SizedBox(height: 20),

              // 6. Privacy
              SwitchListTile(
                title: Text(
                  'Make Public',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Allow others to see this recipe',
                  style: theme.textTheme.bodySmall,
                ),
                value: _isPublic,
                activeColor: theme.colorScheme.primary,
                onChanged: (v) => setState(() => _isPublic = v),
              ),

              const SizedBox(height: 30),

              // 7. Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isSaving ? null : _handleSubmit,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? "Save Changes" : "Publish Recipe",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(
    ThemeData theme,
    String label,
    List<String> list,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSectionLabel(theme, label),
            IconButton(
              icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
              onPressed: () => _openAddItemModal(type: type),
            ),
          ],
        ),
        // it is like convert the map into list of pairs(key, value)
        ...list.asMap().entries.map(
          (e) => buildDynamicItemTile(
            theme: theme,
            index: e.key,
            value: e.value,
            onRemove: () => setState(() => list.removeAt(e.key)),
          ),
        ),
      ],
    );
  }
}
