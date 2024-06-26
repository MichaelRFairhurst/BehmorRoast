import 'package:behmor_roast/src/config/routes.dart';
import 'package:behmor_roast/src/config/theme.dart';
import 'package:behmor_roast/src/roast/providers.dart';
import 'package:behmor_roast/src/sign_in/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).value;

    // Preload bean data.
    ref.read(beansProvider);

    Future.delayed(const Duration(seconds: 2)).then((_) {
      context.go(Routes.overview);
    });

    return Scaffold(
      body: Center(
        child: Text(
          'Welcome ${user!.displayName}!',
          style: RoastAppTheme.welcomeTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
