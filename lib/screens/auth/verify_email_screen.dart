import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../home/main_navigation.dart';

/// Email verification screen
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  
  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isVerified = await authProvider.checkEmailVerified();
    
    setState(() {
      _isChecking = false;
    });
    
    if (!mounted) return;
    
    if (isVerified) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Helpers.showErrorSnackBar(
        context,
        'Email not verified yet. Please check your inbox.',
      );
    }
  }
  
  Future<void> _resendEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.sendEmailVerification();
    
    if (!mounted) return;
    
    Helpers.showSuccessSnackBar(
      context,
      'Verification email sent! Please check your inbox.',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          TextButton(
            onPressed: () async {
              await authProvider.signOut();
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentYellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 60,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Verify Your Email',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                'We\'ve sent a verification email to:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.currentUser?.email ?? '',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your inbox and click the verification link to continue.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Check Verification Button
              CustomButton(
                text: 'I\'ve Verified My Email',
                onPressed: _checkVerification,
                isLoading: _isChecking,
              ),
              const SizedBox(height: 16),
              
              // Resend Email Button
              CustomButton(
                text: 'Resend Verification Email',
                onPressed: _resendEmail,
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
