import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:recipe_keeper/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:recipe_keeper/widgets/my_dialog.dart';
import 'package:recipe_keeper/theme/colors.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // it could be alternatively done with onchanged and state variables
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // to control form validation
  final GlobalKey<FormState> myKey = GlobalKey<FormState>();
  // to toggle password visibility icon (it is hidden by default)
  bool _obscurePassword = true;

  // dispose method to free up memory used by controllers and avoid memory leaks
  // (Without it, these resources keep running or holding memory even after the UI element is gone, slowing down the app.)
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // validation before send request to firebase
    if (!myKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        // or Navigator.pushReplacementNamed
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/authwrapper',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => MyDialog(
            title: 'Sign-In Failed',
            message: _mapErrorCodeToMessage(
              e.code, // e.code gives the specific error code as string
            ), // convert error code to user-friendly message
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const MyDialog(
            title: 'Connection Error ⚠️',
            message: 'Check your internet connection and try again.',
          ),
        );
      }
    }
  }

  String _mapErrorCodeToMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'The email or password you entered is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      default:
        return 'An error occurred during sign-in.';
    }
  }

  Future<void> _handleForgotPassword(AuthProvider auth) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email first to reset your password.',
          ),
        ),
      );
      return;
    }

    try {
      await auth.sendPasswordReset(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Check your email.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Preventing Double Submission and showing loading indicator
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      // SafeArea used to avoid status bar overlap and notches, it adds padding as needed
      body: SafeArea(
        child: Form(
          key: myKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text('Welcome Back!', style: textTheme.headlineMedium),
                Text('Login to continue...', style: textTheme.bodyMedium),
                const SizedBox(height: 32),

                TextFormField(
                  controller: emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email address",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Enter a valid email address \ne.g., user@example.com';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Theme.of(context).hintColor,
                      ),
                      onPressed: () {
                        // Toggle the state
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      auth.isLoading ? null : _handleForgotPassword(auth);
                    },
                    child: const Text('Forgot your password?'),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                  ),
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In'),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        '/registerscreen',
                      ),
                      child: const Text('Register now'),
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
  Note:
  - This SignIn screen uses TextFormFields with validation for email and password.
  - It includes a loading indicator to prevent double submissions.
  - Error messages from Firebase are mapped to user-friendly messages.
  - The password field has a toggle for visibility.


            ┌─────────────────────┐
          │    Open SignIn      │
          └─────────┬──────────┘
                    │
                    ▼
          ┌─────────────────────┐
          │ Enter Email &       │
          │ Password            │
          └─────────┬──────────┘
                    │
                    ▼
          ┌─────────────────────┐
          │ Press SignIn Button  │
          └─────────┬──────────┘
                    │
                    ▼
          ┌─────────────────────────────┐
          │  Form Validation (is valid?) │
          └─────────┬───────────┬──────┘
            Yes / Valid       No / Invalid
            ▼                   │
   ┌─────────────────┐          │
   │ Call auth.signIn │         │
   └─────────┬─────────┘        ▼
             │                  ┌───────────────────────┐
             ▼                  | Show Validation Error │
   ┌──────────────────────────┐ └───────────────────────┘
   │ Show Loading Indicator   │
   │ (isLoading = true)       │
   └─────────┬───────────────┘
             │
             ▼
   ┌──────────────────────────┐
   │ Login Success?           │
   └───────┬───────────┬──────┘
       Yes │           No │
           ▼            ▼
 ┌─────────────────┐  ┌────────────────────────┐
 │ AuthWrapper     │  │ Show Error Dialog       │
 │ detects user   │  │ _mapErrorCodeToMessage │
 │ → navigate to  │  │ message                │
 │ Dashboard      │  └────────────────────────┘
 └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Loading = false │
   └─────────────────┘

  
  note for me:
  1.Freeing memory is the process of returning unused RAM back to the system.
  2.memory leak is a programming error where a program fails to release memory it no longer needs,
   causing it to accumulate, slow down the system, and potentially crash the application or OS over time
*/