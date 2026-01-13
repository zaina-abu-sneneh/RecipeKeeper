import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserNameText extends StatelessWidget {
  final TextStyle? style;
  const UserNameText({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return Text("Guest", style: style);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error", style: style);
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text("Recipe Keeper", style: style);
        }

        // Get the name from the Firestore document
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? "Recipe Keeper";

        return Text(name, style: style);
      },
    );
  }
}
