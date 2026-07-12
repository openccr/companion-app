// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';
import 'package:openccr_companion/src/config/presentation/alarm_thresholds_screen.dart';
import 'package:openccr_companion/src/config/presentation/diver_profile_screen.dart';
import 'package:openccr_companion/src/live/presentation/live_data_screen.dart';

// ── Test keys ─────────────────────────────────────────────────────────────────

abstract final class DeviceDetailScreenKeys {
  static const diverProfileAction = Key('detail_diver_profile');
  static const alarmThresholdsAction = Key('detail_alarm_thresholds');
  static const firmwareUpdateAction = Key('detail_firmware_update');
  static const renameButton = Key('detail_rename');
  static const statusHeader = Key('detail_status_header');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({
    super.key,
    required this.name,
    required this.type,
    required this.battery,
    required this.connected,
    this.lastSeen,
  });

  final String name;
  final String type;
  final int battery;
  final bool connected;
  final String? lastSeen;

  Future<void> _showRenameDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextFormField(
          initialValue: name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Device name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            key: DeviceDetailScreenKeys.renameButton,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename',
            onPressed: () => _showRenameDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          _StatusHeader(
            key: DeviceDetailScreenKeys.statusHeader,
            type: type,
            battery: battery,
            connected: connected,
            lastSeen: lastSeen,
            onTap: connected
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LiveDataScreen(name: name),
                      ),
                    )
                : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Quick Actions',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionTile(
            key: DeviceDetailScreenKeys.diverProfileAction,
            icon: Icons.tune,
            label: 'Diver Profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DiverProfileScreen(),
              ),
            ),
          ),
          _ActionTile(
            key: DeviceDetailScreenKeys.alarmThresholdsAction,
            icon: Icons.notifications_outlined,
            label: 'Alarm Thresholds',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AlarmThresholdsScreen(),
              ),
            ),
          ),
          _ActionTile(
            key: DeviceDetailScreenKeys.firmwareUpdateAction,
            icon: Icons.system_update_outlined,
            label: 'Update Firmware',
            subtitle: 'Up to date (v1.4.2)',
            onTap: null,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Info',
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Firmware', value: '1.4.2'),
          _InfoRow(label: 'Hardware', value: 'Rev C'),
          _InfoRow(
            label: 'Serial',
            value: name.replaceFirst('openCCR-', ''),
          ),
        ],
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    super.key,
    required this.type,
    required this.battery,
    required this.connected,
    required this.lastSeen,
    required this.onTap,
  });

  final String type;
  final int battery;
  final bool connected;
  final String? lastSeen;
  final VoidCallback? onTap;

  Color get _batteryColor {
    if (battery > 50) return AppColors.safe;
    if (battery > 20) return AppColors.caution;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Icon(
                connected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                size: AppSpacing.xl,
                color: connected ? AppColors.ocean : AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type, style: AppTextStyles.h6),
                    Text(
                      connected ? 'Connected' : 'Disconnected',
                      style: AppTextStyles.bodySm.copyWith(
                        color:
                            connected ? AppColors.ocean : AppColors.textMuted,
                      ),
                    ),
                    if (!connected && lastSeen != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Last seen: $lastSeen',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              if (connected) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.battery_full, color: _batteryColor),
                    Text(
                      '$battery%',
                      style:
                          AppTextStyles.labelSm.copyWith(color: _batteryColor),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Icon(
          icon,
          color: onTap != null ? AppColors.ocean : AppColors.textMuted,
        ),
        title: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: onTap != null ? null : AppColors.textMuted,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              )
            : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
          Text(value, style: AppTextStyles.monoSm),
        ],
      ),
    );
  }
}
