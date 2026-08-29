import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/theme/app_colors.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!Validators.isValidPhone(_phoneController.text.trim())) return;
    final authProvider = context.read<AuthProvider>();
    await authProvider.sendPhoneVerification(_phoneController.text.trim());
    if (mounted) {
      setState(() => _codeSent = true);
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithPhoneCredential(_verificationId!, _codeController.text.trim());
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Sign In')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                keyboardType: TextInputType.phone,
                enabled: !_codeSent,
              ),
              const SizedBox(height: 16),
              if (!_codeSent)
                FilledButton(onPressed: _sendCode, child: const Text('Send Verification Code'))
              else ...[
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Verification Code', prefixIcon: Icon(Icons.sms_outlined)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _verifyCode, child: const Text('Verify and Sign In')),
              ],
              if (context.watch<AuthProvider>().errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(context.watch<AuthProvider>().errorMessage!, style: const TextStyle(color: AppColors.safety), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 16),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
            ],
          ),
        ),
      ),
    );
  }
}
