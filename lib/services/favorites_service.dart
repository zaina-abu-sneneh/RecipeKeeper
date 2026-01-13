import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Its only job is to handle data.
class FavoritesService {
  // Architecture NFR called the Singleton Pattern.
  // Private Constructor -> _ means "only this file can use this." It prevents other files from creating a new FavoritesService().
  // More than one screen uses it, but they are all using the exact same object in the computer's memory.
  FavoritesService._();
  // It means the entire app shares one single "manager" for favorites.
  static final instance = FavoritesService._();

  //FirebaseFirestore.instance: This is the API entry point to your database. It’s like opening the door to your storage room.
  final _db = FirebaseFirestore.instance;
  // NFR: Security
  final _auth = FirebaseAuth.instance;

  //Stream: A pipe of data that stays open.
  //Set: A collection of unique items (like a List, but faster for searching).
  //String: The Recipe IDs are stored as text.
  // NFR: Performance -> Set makes checking _isFavorited almost instantaneous on the UI.
  /*
  1. The "Live Listener" Flow (The Stream)
  This part of the code is always running in the background. It’s like a person watching a scoreboard and shouting the score every time it changes.
  Start: The app asks, "Is anyone logged in?"
  Decision: * No? Tell the app the list is empty.
  Yes? Look up that specific User's ID (UID).
  The "Pipe": Open a direct connection to that user's folder in Firestore.
  Translation: Take the raw database data (JSON) and turn it into a clean list of words (Set).
  Update: Whenever a change happens in the cloud, push the new list through the "pipe" to the screen.
  */
  Stream<Set<String>> get favoritesStream {
    //authStateChanges(): A listener that shouts every time a user Logs In or Logs Out.
    //If logged in: It returns a User object (with an ID, Email, etc.).
    //If logged out: It returns null.
    //asyncExpand: This "transforms" one stream into another. If the user changes, the data stream must also change.
    //The asyncExpand "sensor" sees that null, triggers your if block, and automatically switches the output to an empty set.
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(<String>{});
      }

      // snapshots(): It means Real-time. If you change a value in the Firebase console, the app screen moves instantly.
      //.map(): It takes "Database Language" (JSON/Maps) and translates it into "Flutter Language" (Sets of Strings).
      return _db.collection('Users').doc(user.uid).snapshots().map((doc) {
        if (!doc.exists) return <String>{};
        final data = doc.data();
        final List<dynamic> favs = data?['favorites'] ?? [];
        return favs.map((e) => e.toString()).toSet();
      });
    });
  }

  /*
  2. The "Button Press" Flow (Toggle Favorite)
    This happens only when you actually tap the heart icon on a recipe. It’s a series of "If/Then" steps.+
    Step A: Check if a user is logged in. If not, stop (you can't save favorites if we don't know who you are!).
    Step B: Ask the database: "What does this user's list look like right now?"
    Step C (The Logic):
      IF the Recipe ID is already in the list → Send a command to REMOVE it.
      ELSE (if it's not there) → Send a command to ADD it.
    Step D: Use merge: true so we don't accidentally delete the user's name or email while updating the favorites.
   */
  Future<void> toggleFavorite(String recipeId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _db.collection('Users').doc(user.uid);

    // 1. Get the current document to check if the ID already exists
    final doc = await userRef.get();
    final List<dynamic> currentFavs = doc.data()?['favorites'] ?? [];

    if (currentFavs.contains(recipeId)) {
      // 2. If it's already a favorite, REMOVE it
      await userRef.update({
        'favorites': FieldValue.arrayRemove([recipeId]),
      });
    } else {
      // 3. If it's not a favorite, ADD it
      await userRef.set({
        'favorites': FieldValue.arrayUnion([recipeId]),
      }, SetOptions(merge: true)); // NFR : Safity
      //SetOptions(merge: true): This ensures that if the User document doesn't exist yet, it creates it without deleting other user data.
    }
  }
}

//"The difference lies in the output type and lifecycle. 
// While async is a keyword used to handle a single asynchronous event returning a Future, 
// asyncExpand is a Stream operator. 
// I used asyncExpand because I needed to transform the Authentication Stream into a Firestore Snapshots Stream.
// This ensures that the lifecycle of my database listener is perfectly tied to the lifecycle of the user's login session."