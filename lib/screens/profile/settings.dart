import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for auth
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_keeper/theme/colors.dart';
import 'package:recipe_keeper/providers/theme_provider.dart';
import 'package:recipe_keeper/widgets/username_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Logout Logic
  Future<void> _handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Clear the navigation stack and go to login
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  // Delete Account Logic
  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text("Delete Account?"),
        content: const Text(
          "This will permanently delete your login credentials. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rubyRed),
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // 1. Pop the dialog immediately so it doesn't get stuck
                  Navigator.pop(ctx);

                  // 2. Delete the user
                  await user.delete();

                  // 3. Navigate back to the start
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/', // Go to the root (AuthWrapper)
                      (route) => false,
                    );
                  }
                }
              } on FirebaseAuthException catch (e) {
                if (context.mounted) {
                  if (e.code == 'requires-recent-login') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Security: Please log out and back in to delete your account.",
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.message}")),
                    );
                  }
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName(String newName, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || newName.trim().isEmpty) return;

    try {
      // 1. Update Firestore (This triggers your UserNameText widget instantly)
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update(
        {'name': newName.trim()},
      );

      // 2. Update Firebase Auth Profile
      await user.updateDisplayName(newName.trim());

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated!")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showEditNameDialog(BuildContext context) {
    // Pre-fill the controller with the current display name
    final currentName = FirebaseAuth.instance.currentUser?.displayName ?? "";
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Name"),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "New Name",
            hintText: "Enter your full name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            onPressed: () {
              _updateName(nameController.text, context);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final titleStyle = textTheme.bodyLarge;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(context, 'User Account'),
          ListTile(
            leading: Icon(Icons.edit_note, color: theme.colorScheme.primary),
            title: const Text("Change Name"),
            // We use your custom widget here to show the current name as a subtitle
            subtitle: UserNameText(
              style: TextStyle(color: theme.hintColor, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditNameDialog(context),
          ),
          _buildHeader(context, "Display Theme"),

          RadioListTile<String>(
            title: Text("Light Mode", style: titleStyle),
            value: 'light',
            groupValue: themeProvider.themeString,
            onChanged: (val) => themeProvider.setTheme(val!),
            activeColor: theme.colorScheme.primary,
          ),
          RadioListTile<String>(
            title: Text("Dark Mode", style: titleStyle),
            value: 'dark',
            groupValue: themeProvider.themeString,
            onChanged: (val) => themeProvider.setTheme(val!),
            activeColor: theme.colorScheme.primary,
          ),

          const SizedBox(height: 24),
          _buildHeader(context, "Account"),

          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.primary),
            title: Text("Sign Out", style: titleStyle),
            onTap: () => _handleSignOut(context),
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.rubyRed),
            title: const Text(
              "Delete Account",
              style: TextStyle(
                color: AppColors.rubyRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () =>
                _showDeleteConfirmation(context), // delete confirmation
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color:
              Theme.of(context).textTheme.labelSmall?.color ??
              AppColors.mediumGray,
        ),
      ),
    );
  }
}
