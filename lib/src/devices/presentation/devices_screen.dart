// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';
import 'package:openccr_companion/src/ble/domain/ble_device.dart';
import 'package:openccr_companion/src/ble/domain/ble_scan_state.dart';
import 'package:openccr_companion/src/ble/presentation/ble_providers.dart';
import 'package:openccr_companion/src/ble/presentation/pairing_screen.dart';
import 'package:openccr_companion/src/devices/presentation/device_detail_screen.dart';

// ── Stub data ─────────────────────────────────────────────────────────────────

class _PairedDevice {
  const _PairedDevice({
    required this.name,
    required this.type,
    required this.battery,
    required this.connected,
    required this.synced,
    this.lastSeen,
  });

  final String name;
  final String type;
  final int battery;
  final bool connected;
  final bool synced;
  final String? lastSeen;
}

const _kPaired = [
  _PairedDevice(
    name: 'openCCR-F3A2',
    type: 'CCR Unit',
    battery: 87,
    connected: true,
    synced: true,
  ),
  _PairedDevice(
    name: 'openCCR-HUD-12',
    type: 'HUD',
    battery: 62,
    connected: false,
    synced: false,
    lastSeen: '3 days ago',
  ),
];

// ── Test keys ─────────────────────────────────────────────────────────────────

abstract final class DevicesScreenKeys {
  static const yourDevicesHeader = Key('devices_your_devices_header');
  static const nearbyHeader = Key('devices_nearby_header');
  static const nearbySpinner = Key('devices_nearby_spinner');
  static const nearbyPermissionMessage = Key('devices_nearby_permission');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(bleScanProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        _SectionHeader(
          key: DevicesScreenKeys.yourDevicesHeader,
          title: 'Your Devices',
        ),
        for (final d in _kPaired) _PairedCard(device: d),
        const SizedBox(height: AppSpacing.sm),
        _SectionHeader(
          key: DevicesScreenKeys.nearbyHeader,
          title: 'Nearby',
        ),
        _NearbyContent(scanState: scanState),
      ],
    );
  }
}

// ── Nearby content ────────────────────────────────────────────────────────────

class _NearbyContent extends StatelessWidget {
  const _NearbyContent({required this.scanState});

  final BleScanState scanState;

  @override
  Widget build(BuildContext context) {
    return switch (scanState) {
      BleScanIdle() => const _NearbySpinner(),
      BleScanScanning(:final devices) when devices.isEmpty =>
        const _NearbySpinner(),
      BleScanScanning(:final devices) => Column(
          children: [for (final d in devices) _NearbyCard(device: d)],
        ),
      BleScanPermissionDenied() => const _NearbyMessage(
          key: DevicesScreenKeys.nearbyPermissionMessage,
          icon: Icons.bluetooth_disabled,
          message: 'Bluetooth permission required',
        ),
      BleScanError(:final message) => _NearbyMessage(
          icon: Icons.error_outline,
          message: message,
        ),
    };
  }
}

class _NearbySpinner extends StatelessWidget {
  const _NearbySpinner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              key: DevicesScreenKeys.nearbySpinner,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Scanning for devices\u2026',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyMessage extends StatelessWidget {
  const _NearbyMessage({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({super.key, required this.title});

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

class _PairedCard extends StatelessWidget {
  const _PairedCard({required this.device});

  final _PairedDevice device;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DeviceDetailScreen(
              name: device.name,
              type: device.type,
              battery: device.battery,
              connected: device.connected,
              lastSeen: device.lastSeen,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              if (device.connected)
                _BatteryIcon(percent: device.battery)
              else
                const Icon(
                  Icons.bluetooth_disabled,
                  size: 32,
                  color: AppColors.textMuted,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(device.name, style: AppTextStyles.label),
                        if (!device.synced) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.caution,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      device.type,
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.textMuted),
                    ),
                    if (!device.connected && device.lastSeen != null)
                      Text(
                        'Last seen: ${device.lastSeen}',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              _StatusChip(connected: device.connected),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.device});

  final BleDevice device;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            const Icon(Icons.bluetooth, color: AppColors.ocean),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: AppTextStyles.label),
                  Text(
                    '${device.rssi} dBm',
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PairingScreen(
                    deviceId: device.id,
                    deviceName: device.name,
                  ),
                ),
              ),
              child: const Text('Pair'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatteryIcon extends StatelessWidget {
  const _BatteryIcon({required this.percent});

  final int percent;

  Color get _color {
    if (percent > 50) return AppColors.safe;
    if (percent > 20) return AppColors.caution;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.battery_full, size: 32, color: _color),
        Positioned(
          bottom: 5,
          child: Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.bg,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: connected ? AppColors.safeTint15 : AppColors.bgSubtle,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        connected ? 'Connected' : 'Disconnected',
        style: AppTextStyles.badge.copyWith(
          color: connected ? AppColors.safe : AppColors.textMuted,
        ),
      ),
    );
  }
}
