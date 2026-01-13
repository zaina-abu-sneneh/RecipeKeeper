// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_keeper/providers/auth_provider.dart';
import 'package:recipe_keeper/widgets/my_dialog.dart';
import 'package:recipe_keeper/theme/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> myKey = GlobalKey<FormState>();
  bool _obscurePassword = true; // Password is hidden by default
  bool _obscureConfirmPassword = true; // Confirm Password is hidden by default
  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (myKey.currentState!.validate()) {
      try {
        await auth.register(
          fullNameController.text.trim(),
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/authwrapper',
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        showDialog(
          context: context,
          builder: (_) => MyDialog(
            title: 'Sign-Up Failed',
            message: _mapSignUpErrorCodeToMessage(e.code),
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => MyDialog(title: 'Error', message: e.toString()),
        );
      }
    }
  }

  String _mapSignUpErrorCodeToMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Added loading state(Preventing Double Submission, Duplicate Data)
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: myKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text('Create Account', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Join RecipeKeeper', style: theme.textTheme.titleLarge),
                Text(
                  'Start organizing your recipes today',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Full Name
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your name'
                      : null,

                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    helperText: 'Min. 8 chars, 1 uppercase, 1 number, 1 symbol',
                    helperMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    // Define the Regexp
                    final passwordRegExp = RegExp(
                      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                    );

                    if (!passwordRegExp.hasMatch(value)) {
                      return 'Password is too weak:\n• 8+ characters\n• Uppercase & Lowercase\n• Number & Special character';
                    }

                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () {
                          if (myKey.currentState!.validate()) _signUp();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up'),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have account?'),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        '/loginscreen',
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
            ┌─────────────────────┐
          │    Open SignUp      │
          └─────────┬──────────┘
                    │
                    ▼
          ┌─────────────────────┐
          │ Enter Name, Email,  │
          │ Password, Confirm   │
          └─────────┬──────────┘
                    │
                    ▼
          ┌─────────────────────┐
          │ Press SignUp Button │
          └─────────┬──────────┘
                    │
                    ▼
          ┌─────────────────────────────┐
          │ Form Validation (Valid?)     │
          └─────────┬───────────┬──────┘
            Yes / Valid       No / Invalid
            ▼                  │
   ┌─────────────────┐        │
   │ Call authProvider│        │
   │ register()      │        │
   └─────────┬─────────┘      │
             │                │
             ▼                │
   ┌──────────────────────────┐
   │ Show Loading Indicator    │
   │ (isLoading = true)        │
   └─────────┬───────────────┘
             │
             ▼
   ┌──────────────────────────┐
   │ Registration Success?     │
   └───────┬───────────┬──────┘
       Yes │           No │
           ▼            ▼
 ┌─────────────────┐  ┌────────────────────────┐
 │ AuthWrapper     │  │ Show Error Dialog       │
 │ detects user   │  │ _mapSignUpErrorCodeToMessage │
 │ → navigate to  │  │ message                │
 │ Dashboard      │  └────────────────────────┘
 └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Loading = false │
   └─────────────────┘

*/
