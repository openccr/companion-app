// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';

abstract final class HomeScreenKeys {
  static const ValueKey<String> screen = ValueKey<String>('home_screen');
  static const ValueKey<String> heroSection = ValueKey<String>('home_hero');
  static const ValueKey<String> heading = ValueKey<String>('home_heading');
  static const ValueKey<String> subtitle = ValueKey<String>('home_subtitle');
  static const ValueKey<String> brandWordmark =
      ValueKey<String>('home_brand_wordmark');
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: HomeScreenKeys.screen,
      backgroundColor: AppColors.bg,
      appBar: _buildNavBar(),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildNavBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(AppSpacing.navBarHeight),
      child: Container(
        height: AppSpacing.navBarHeight,
        decoration: const BoxDecoration(
          color: AppColors.bg,
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              children: [
                _BrandWordmark(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return RichText(
      key: HomeScreenKeys.brandWordmark,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'open',
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.navy),
          ),
          TextSpan(
            text: 'CCR',
            style: AppTextStyles.bodyLg.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: HomeScreenKeys.heroSection,
      color: AppColors.bgSubtle,
      child: Stack(
        children: [
          const Positioned.fill(
            child: _GridOverlay(
              cellSize: AppSpacing.gridCellSize,
              color: AppColors.gridLight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome to OpenCCR companion app',
                  key: HomeScreenKeys.heading,
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Diver interface for CCR controllers',
                  key: HomeScreenKeys.subtitle,
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay({required this.cellSize, required this.color});

  final double cellSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(cellSize: cellSize, color: color),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.cellSize, required this.color});

  final double cellSize;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize || oldDelegate.color != color;
}
