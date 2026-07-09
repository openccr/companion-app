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

abstract final class DeviceListScreenKeys {
  static const ValueKey<String> screen = ValueKey<String>('device_list_screen');
  static const ValueKey<String> scanStatus =
      ValueKey<String>('device_list_scan_status');
  static const ValueKey<String> deviceList =
      ValueKey<String>('device_list_list');
  static const ValueKey<String> permissionPrompt =
      ValueKey<String>('device_list_permission_prompt');

  static ValueKey<String> deviceTile(String id) =>
      ValueKey<String>('device_tile_$id');
}

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(bleScanProvider);

    return Scaffold(
      key: DeviceListScreenKeys.screen,
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Find Device', style: AppTextStyles.h5),
      ),
      body: switch (scanState) {
        BleScanIdle() => const SizedBox.shrink(),
        BleScanScanning(:final devices) when devices.isEmpty =>
          _ScanningSpinner(),
        BleScanScanning(:final devices) => _DeviceList(devices: devices),
        BleScanPermissionDenied() => _PermissionDeniedView(
            onGrant: () =>
                ref.read(bleScanProvider.notifier).requestPermissions(),
          ),
        BleScanError(:final message) => _ErrorView(
            message: message,
            onRetry: () => ref.read(bleScanProvider.notifier).retry(),
          ),
      },
    );
  }
}

class _ScanningSpinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.ocean),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Scanning...',
            key: DeviceListScreenKeys.scanStatus,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.devices});

  final List<BleDevice> devices;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: DeviceListScreenKeys.deviceList,
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: devices.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.border, height: 1),
      itemBuilder: (context, i) => _DeviceTile(device: devices[i]),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device});

  final BleDevice device;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: DeviceListScreenKeys.deviceTile(device.id),
      title: Text(device.name, style: AppTextStyles.labelLg),
      subtitle: Text(
        'RSSI: ${device.rssi} dBm'
        '${device.firmwareVersion != null ? ' · FW ${device.firmwareVersion}' : ''}',
        style: AppTextStyles.labelSm,
      ),
      trailing: device.hasCompanion
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warningTint10,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                'PAIRED',
                style: AppTextStyles.badge
                    .copyWith(color: AppColors.warning, fontSize: 10),
              ),
            )
          : const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PairingScreen(
              deviceId: device.id,
              deviceName: device.name,
            ),
          ),
        );
      },
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: DeviceListScreenKeys.permissionPrompt,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bluetooth_disabled,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Bluetooth access required',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Grant Bluetooth access to scan for your CCR controller.',
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onGrant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ocean,
                foregroundColor: AppColors.bg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Grant Bluetooth Access'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
