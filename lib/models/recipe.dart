import 'package:cloud_firestore/cloud_firestore.dart';

// to prevent dealing with Map<String, dynamic> everywhere, we create a Recipe model
// also type safety e.g. recipe['title'] vs recipe.title
class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String ownerId;
  final bool isPublic;
  final List<String> ingredients;
  final List<String> instructions;
  final Timestamp timestamp;
  final String? category;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ownerId,
    required this.isPublic,
    required this.ingredients,
    required this.instructions,
    required this.timestamp,
    this.category,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'ownerId': ownerId,
      'isPublic': isPublic,
      'category': category,
    };
  }

  // Factory constructor for safe parsing from a Firestore DocumentSnapshot
  // control what it will return if a field is missing or of the wrong type, meaning that there is checking for the data before assigning it to the model fields
  // (Readability, Flexibility) to from where I will get the data
  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // function to safely convert Firestore's List<dynamic> to List<String>
    List<String> safeCastList(dynamic field) {
      if (field is List) {
        // Ensures every item in the list is treated as a String
        return field.map((item) => item.toString()).toList();
      }
      return []; // Returns an empty list if the field is missing or wrong type
    }

    return Recipe(
      id: doc.id,
      title:
          data?['title'] as String? ??
          'Untitled Recipe', // (Robustness) the app won't crash if some data are missing
      imageUrl:
          data?['imageUrl'] as String? ??
          'https://www.swankyrecipes.com/wp-content/uploads/2023/07/placeholder.png',
      ownerId: data?['ownerId'] as String? ?? 'unknown_user',
      isPublic: data?['isPublic'] as bool? ?? false,
      timestamp: data?['timestamp'] as Timestamp? ?? Timestamp.now(),

      // Safely extracting the two new array fields
      ingredients: safeCastList(data?['ingredients']),
      instructions: safeCastList(data?['instructions']),
      category: data?['category'] as String?,
    );
  }
}
