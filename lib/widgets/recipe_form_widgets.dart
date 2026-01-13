import 'package:flutter/material.dart';
import 'package:recipe_keeper/theme/colors.dart';

// Shared Input Decoration
InputDecoration customInputDecoration(ThemeData theme, String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: theme.brightness == Brightness.light
        ? Colors.grey[100]
        : Colors.white10,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

// Section Labels
Widget buildSectionLabel(ThemeData theme, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    ),
  );
}

// Image Preview Card
Widget buildImagePreviewCard({
  required ThemeData theme,
  required String imageUrl,
  required TextEditingController controller,
}) {
  final isDark = theme.brightness == Brightness.dark;

  return Container(
    height: 200,
    width: double.infinity,
    decoration: BoxDecoration(
      color: isDark ? theme.colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(20),
      image: imageUrl.isNotEmpty
          ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (imageUrl.isEmpty)
          Expanded(
            child: Icon(
              Icons.add_a_photo_outlined,
              size: 50,
              color: theme.hintColor,
            ),
          ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.7)
                : Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Paste Image URL here...',
              hintStyle: TextStyle(color: theme.hintColor, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    ),
  );
}

// Dynamic List Item
Widget buildDynamicItemTile({
  required ThemeData theme,
  required int index,
  required String value,
  required VoidCallback onRemove,
}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    color: theme.colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: theme.dividerColor),
    ),
    child: ListTile(
      dense: true, //Dense list tiles default to a smaller height.
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          '${index + 1}',
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
      title: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.remove_circle_outline,
          color: AppColors.rubyRed,
          size: 20,
        ),
        onPressed: onRemove,
      ),
    ),
  );
}

// Category Chip Selector
Widget buildCategorySelector({
  required ThemeData theme,
  required List<String> categories,
  required String? selectedCategory,
  required Function(String) onSelected,
}) {
  return Wrap(
    spacing: 8,
    children: categories.map((cat) {
      final isSelected = selectedCategory == cat;
      return ChoiceChip(
        label: Text(cat),
        selected: isSelected,
        onSelected: (selected) => onSelected(cat),
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        backgroundColor: theme.colorScheme.surface,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.textTheme.bodySmall?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }).toList(),
  );
}
