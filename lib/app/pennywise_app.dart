import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/widgets/auth_gate.dart';
import '../features/goals/data/goals_repository.dart';
import '../features/goals/providers/goals_provider.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/transactions/data/transactions_repository.dart';
import '../features/transactions/providers/transactions_provider.dart';
import '../theme/app_theme.dart';

class PennyWiseApp extends StatelessWidget {
  const PennyWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FirebaseFirestore.instance),
        Provider(create: (_) => firebase_auth.FirebaseAuth.instance),
        Provider(
          create: (context) =>
              ProfileRepository(context.read<FirebaseFirestore>()),
        ),
        Provider(
          create: (context) =>
              TransactionsRepository(context.read<FirebaseFirestore>()),
        ),
        Provider(
          create: (context) =>
              GoalsRepository(context.read<FirebaseFirestore>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<firebase_auth.FirebaseAuth>(),
            context.read<ProfileRepository>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (context) =>
              ProfileProvider(context.read<ProfileRepository>()),
          update: (_, authProvider, profileProvider) {
            profileProvider!.bindUser(authProvider.firebaseUser);
            return profileProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionsProvider>(
          create: (context) =>
              TransactionsProvider(context.read<TransactionsRepository>()),
          update: (_, authProvider, transactionsProvider) {
            transactionsProvider!.bindUser(authProvider.firebaseUser);
            return transactionsProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, GoalsProvider>(
          create: (context) => GoalsProvider(context.read<GoalsRepository>()),
          update: (_, authProvider, goalsProvider) {
            goalsProvider!.bindUser(authProvider.firebaseUser);
            return goalsProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'PennyWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
