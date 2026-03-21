import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/providers/profile_provider.dart';
import '../../home/screens/home_controller.dart';
import '../providers/auth_provider.dart';
import '../screens/auth_page.dart';
import '../screens/onboarding_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, authProvider, profileProvider, _) {
        if (!authProvider.isInitialized) {
          return const _LoadingScaffold(message: 'Initializing PennyWise...');
        }

        if (!authProvider.hasSeenOnboarding) {
          return OnboardingPage(
            userName: profileProvider.profile?.name,
            onComplete: authProvider.completeOnboarding,
          );
        }

        if (!authProvider.isAuthenticated) {
          return const AuthPage();
        }

        if (profileProvider.isLoading && profileProvider.profile == null) {
          return const _LoadingScaffold(message: 'Loading your profile...');
        }

        return const HomeController();
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}
