// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openccr_companion/shared/theme/app_theme.dart';
import 'package:openccr_companion/src/home/presentation/home_screen.dart';

void main() => runApp(const ProviderScope(child: OpenCcrApp()));

class OpenCcrApp extends StatelessWidget {
  const OpenCcrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'openCCR',
      theme: AppTheme.light(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
