// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';
import 'package:openccr_companion/src/config/presentation/alarm_thresholds_screen.dart';
import 'package:openccr_companion/src/config/presentation/dive_settings_screen.dart';
import 'package:openccr_companion/src/config/presentation/gas_settings_screen.dart';

// ── Test keys ─────────────────────────────────────────────────────────────────

abstract final class ConfigScreenKeys {
  static const diveSettingsRow = Key('config_dive_settings');
  static const gasSettingsRow = Key('config_gas_settings');
  static const alarmThresholdsRow = Key('config_alarm_thresholds');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        _SectionHeader('General Settings'),
        _ConfigRow(
          key: ConfigScreenKeys.diveSettingsRow,
          icon: Icons.scuba_diving_outlined,
          title: 'Dive Settings',
          subtitle: 'Setpoint, gradient factors',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DiveSettingsScreen(),
            ),
          ),
        ),
        _ConfigRow(
          key: ConfigScreenKeys.gasSettingsRow,
          icon: Icons.air_outlined,
          title: 'Gas Settings',
          subtitle: 'Gas mix, conservatism',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const GasSettingsScreen(),
            ),
          ),
        ),
        _ConfigRow(
          key: ConfigScreenKeys.alarmThresholdsRow,
          icon: Icons.notifications_outlined,
          title: 'Alarm Thresholds',
          subtitle: 'PO₂, scrubber, CO₂ limits',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AlarmThresholdsScreen(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionHeader('Per Device Type'),
        _ConfigRow(
          icon: Icons.settings_outlined,
          title: 'CCR Controller',
          subtitle: 'openCCR unit settings',
          onTap: null,
        ),
        _ConfigRow(
          icon: Icons.visibility_outlined,
          title: 'HUD',
          subtitle: 'Heads-up display settings',
          onTap: null,
        ),
        const SizedBox(height: AppSpacing.sm),
        _SectionHeader('Per-Device Settings'),
        _ConfigRow(
          icon: Icons.devices_outlined,
          title: 'openCCR-F3A2',
          subtitle: 'CCR Unit · Connected',
          onTap: null,
        ),
        _ConfigRow(
          icon: Icons.devices_outlined,
          title: 'openCCR-HUD-12',
          subtitle: 'HUD · Disconnected',
          onTap: null,
        ),
      ],
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: onTap != null ? AppColors.ocean : AppColors.textMuted,
        ),
        title: Text(title, style: AppTextStyles.body),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: AppColors.ocean)
            : null,
        onTap: onTap,
      ),
    );
  }
}
