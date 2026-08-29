import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.sendPasswordReset(_emailController.text.trim());
    if (mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                if (_sent) ...[
                  const Icon(Icons.check_circle, size: 64, color: AppColors.active),
                  const SizedBox(height: 16),
                  Text('Reset link sent', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Check your email for instructions to reset your password.', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
                ] else ...[
                  Text('Enter your email and we\'ll send you a reset link.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (authProvider.isLoading) {
                        return const FilledButton(onPressed: null, child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)));
                      }
                      return FilledButton(onPressed: _sendReset, child: const Text('Send Reset Link'));
                    },
                  ),
                  if (context.watch<AuthProvider>().errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(context.watch<AuthProvider>().errorMessage!, style: const TextStyle(color: AppColors.safety), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 16),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
