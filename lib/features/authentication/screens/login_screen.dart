import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 48),
                Icon(Icons.health_and_safety_rounded, size: 64, color: AppColors.safety),
                const SizedBox(height: 16),
                Text('SafeShake', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Safety in the Shake of Your Hand', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isLoading) {
                      return const FilledButton(onPressed: null, child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)));
                    }
                    return FilledButton(onPressed: _signIn, child: const Text('Sign In'));
                  },
                ),
                if (context.watch<AuthProvider>().errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(context.watch<AuthProvider>().errorMessage!, style: const TextStyle(color: AppColors.safety), textAlign: TextAlign.center),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(onPressed: _signInWithGoogle, icon: const Icon(Icons.login), label: const Text('Sign in with Google')),
                const SizedBox(height: 16),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/forgot-password'), child: const Text('Forgot password?')),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Don\'t have an account? Sign up')),
                const SizedBox(height: 16),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/phone-auth'), child: const Text('Sign in with phone number')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
