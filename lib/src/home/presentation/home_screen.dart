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

abstract final class HomeScreenKeys {
  static const ValueKey<String> screen = ValueKey<String>('home_screen');
  static const ValueKey<String> heroSection = ValueKey<String>('home_hero');
  static const ValueKey<String> heading = ValueKey<String>('home_heading');
  static const ValueKey<String> subtitle = ValueKey<String>('home_subtitle');
  static const ValueKey<String> brandWordmark =
      ValueKey<String>('home_brand_wordmark');
  static const ValueKey<String> knownDevicesSection =
      ValueKey<String>('home_known_devices');
  static const ValueKey<String> scanSection =
      ValueKey<String>('home_scan_section');

  static ValueKey<String> connectButton(String id) =>
      ValueKey<String>('home_connect_$id');
  static ValueKey<String> pairButton(String id) =>
      ValueKey<String>('home_pair_$id');
  static ValueKey<String> knownDeviceTile(String id) =>
      ValueKey<String>('home_known_tile_$id');
  static ValueKey<String> scanDeviceTile(String id) =>
      ValueKey<String>('home_scan_tile_$id');
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Map<String, bool> _connecting = {};
  final Map<String, String?> _connectError = {};

  Future<void> _connect(String deviceId) async {
    setState(() {
      _connecting[deviceId] = true;
      _connectError[deviceId] = null;
    });
    try {
      await ref.read(bleRepositoryProvider).connect(deviceId);
      if (mounted) setState(() => _connecting[deviceId] = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _connecting[deviceId] = false;
          _connectError[deviceId] = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final knownAsync = ref.watch(knownDevicesProvider);
    final scanState = ref.watch(bleScanProvider);

    // IDs of known devices — used to filter them out of scan results.
    final knownIds = knownAsync.valueOrNull?.map((d) => d.id).toSet() ?? {};

    return Scaffold(
      key: HomeScreenKeys.screen,
      backgroundColor: AppColors.bg,
      appBar: _buildNavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeroSection(),
            _KnownDevicesSection(
              knownAsync: knownAsync,
              connecting: _connecting,
              connectError: _connectError,
              onConnect: _connect,
            ),
            const Divider(color: AppColors.border, height: 1),
            _ScanningSection(
              scanState: scanState,
              knownIds: knownIds,
              onRetry: () => ref.read(bleScanProvider.notifier).retry(),
              onGrantPermission: () =>
                  ref.read(bleScanProvider.notifier).requestPermissions(),
            ),
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
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(children: [_BrandWordmark()]),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

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
    return CustomPaint(painter: _GridPainter(cellSize: cellSize, color: color));
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
  bool shouldRepaint(_GridPainter old) =>
      old.cellSize != cellSize || old.color != color;
}

// ---------------------------------------------------------------------------
// Known devices
// ---------------------------------------------------------------------------

class _KnownDevicesSection extends StatelessWidget {
  const _KnownDevicesSection({
    required this.knownAsync,
    required this.connecting,
    required this.connectError,
    required this.onConnect,
  });

  final AsyncValue<List<BleDevice>> knownAsync;
  final Map<String, bool> connecting;
  final Map<String, String?> connectError;
  final Future<void> Function(String deviceId) onConnect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: HomeScreenKeys.knownDevicesSection,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Devices', style: AppTextStyles.h5),
          const SizedBox(height: AppSpacing.sm),
          switch (knownAsync) {
            AsyncLoading() => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.ocean),
                ),
              ),
            AsyncError() => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'Could not load paired devices.',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                ),
              ),
            AsyncData(:final value) when value.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'No paired devices yet. Use the scanner below to pair.',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                ),
              ),
            AsyncData(:final value) => Column(
                children: value
                    .map(
                      (d) => _KnownDeviceTile(
                        device: d,
                        isConnecting: connecting[d.id] ?? false,
                        error: connectError[d.id],
                        onConnect: () => onConnect(d.id),
                      ),
                    )
                    .toList(),
              ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

class _KnownDeviceTile extends StatelessWidget {
  const _KnownDeviceTile({
    required this.device,
    required this.isConnecting,
    required this.error,
    required this.onConnect,
  });

  final BleDevice device;
  final bool isConnecting;
  final String? error;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: HomeScreenKeys.knownDeviceTile(device.id),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: AppTextStyles.labelLg),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      error!,
                      style: AppTextStyles.labelSm
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 96,
            child: ElevatedButton(
              key: HomeScreenKeys.connectButton(device.id),
              onPressed: isConnecting ? null : onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: AppColors.bg,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
              child: isConnecting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.bg,
                      ),
                    )
                  : const Text('Connect'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scanning
// ---------------------------------------------------------------------------

class _ScanningSection extends StatelessWidget {
  const _ScanningSection({
    required this.scanState,
    required this.knownIds,
    required this.onRetry,
    required this.onGrantPermission,
  });

  final BleScanState scanState;
  final Set<String> knownIds;
  final VoidCallback onRetry;
  final VoidCallback onGrantPermission;

  @override
  Widget build(BuildContext context) {
    final isScanning = scanState is BleScanScanning;

    return Padding(
      key: HomeScreenKeys.scanSection,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Nearby Devices', style: AppTextStyles.h5),
              if (isScanning) ...[
                const SizedBox(width: AppSpacing.sm),
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.ocean,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          switch (scanState) {
            BleScanIdle() => const SizedBox.shrink(),
            BleScanScanning(:final devices) => _ScanResults(
                devices: devices,
                knownIds: knownIds,
              ),
            BleScanPermissionDenied() => _PermissionBanner(
                onGrant: onGrantPermission,
              ),
            BleScanError(:final message) => _ScanErrorBanner(
                message: message,
                onRetry: onRetry,
              ),
          },
        ],
      ),
    );
  }
}

class _ScanResults extends StatelessWidget {
  const _ScanResults({required this.devices, required this.knownIds});

  final List<BleDevice> devices;
  final Set<String> knownIds;

  @override
  Widget build(BuildContext context) {
    final unpaired = devices.where((d) => !knownIds.contains(d.id)).toList();

    if (unpaired.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          'Searching for openCCR devices…',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      children: unpaired.map((d) => _ScanDeviceTile(device: d)).toList(),
    );
  }
}

class _ScanDeviceTile extends StatelessWidget {
  const _ScanDeviceTile({required this.device});

  final BleDevice device;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: HomeScreenKeys.scanDeviceTile(device.id),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: AppTextStyles.labelLg),
                Text(
                  'RSSI: ${device.rssi} dBm'
                  '${device.firmwareVersion != null ? ' · FW ${device.firmwareVersion}' : ''}',
                  style: AppTextStyles.labelSm,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 72,
            child: OutlinedButton(
              key: HomeScreenKeys.pairButton(device.id),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PairingScreen(
                      deviceId: device.id,
                      deviceName: device.name,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ocean,
                side: const BorderSide(color: AppColors.ocean),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
              child: const Text('Pair'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.bluetooth_disabled,
            color: AppColors.textMuted, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Bluetooth access required to scan for devices.',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: onGrant,
          child: const Text('Grant'),
        ),
      ],
    );
  }
}

class _ScanErrorBanner extends StatelessWidget {
  const _ScanErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.warning, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
