// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openccr_companion/shared/constants/ble_constants.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';
import 'package:openccr_companion/src/ble/domain/ble_pairing_state.dart';
import 'package:openccr_companion/src/ble/presentation/ble_providers.dart';

abstract final class PairingScreenKeys {
  static const ValueKey<String> screen = ValueKey<String>('pairing_screen');
  static const ValueKey<String> keyField =
      ValueKey<String>('pairing_key_field');
  static const ValueKey<String> submitButton =
      ValueKey<String>('pairing_submit_button');
  static const ValueKey<String> statusText =
      ValueKey<String>('pairing_status_text');
}

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  final String deviceId;
  final String deviceName;

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _controller = TextEditingController();
  bool _autoPoppedScheduled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blePairingProvider(widget.deviceId));

    // Auto-pop on success after 1.5 s.
    if (state is BlePairingSuccess && !_autoPoppedScheduled) {
      _autoPoppedScheduled = true;
      final nav = Navigator.of(context);
      Future.delayed(const Duration(milliseconds: 1500), () {
        // maybePop is safe even if this is the root route (e.g. in tests).
        if (mounted) nav.maybePop();
      });
    }

    return Scaffold(
      key: PairingScreenKeys.screen,
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(widget.deviceName, style: AppTextStyles.h5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: switch (state) {
          BlePairingConnecting() => const _Spinner(),
          BlePairingAwaitingKey() => _KeyEntryForm(
              controller: _controller,
              onSubmit: _submitKey,
              errorText: null,
            ),
          BlePairingSubmitting() => _KeyEntryForm(
              controller: _controller,
              onSubmit: null,
              errorText: null,
              submitting: true,
            ),
          BlePairingWrongKey(:final remainingAttempts) => _KeyEntryForm(
              controller: _controller,
              onSubmit: _submitKey,
              errorText: remainingAttempts > 0
                  ? 'Wrong key — $remainingAttempts attempt'
                      '${remainingAttempts == 1 ? '' : 's'} remaining'
                  : 'Wrong key',
            ),
          BlePairingLockedOut() => _LockedOutView(),
          BlePairingSuccess() => _SuccessView(),
          BlePairingError(:final message) => _ErrorView(
              message: message,
              onRetry: () => ref
                  .read(blePairingProvider(widget.deviceId).notifier)
                  .retry(),
            ),
          BlePairingIdle() => const _Spinner(),
        },
      ),
    );
  }

  void _submitKey() {
    final key = _controller.text;
    if (key.length != BleConstants.pairingKeyLength) return;
    ref.read(blePairingProvider(widget.deviceId).notifier).submitKey(key);
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.ocean),
    );
  }
}

class _KeyEntryForm extends StatefulWidget {
  const _KeyEntryForm({
    required this.controller,
    required this.onSubmit,
    required this.errorText,
    this.submitting = false,
  });

  final TextEditingController controller;
  final VoidCallback? onSubmit;
  final String? errorText;
  final bool submitting;

  @override
  State<_KeyEntryForm> createState() => _KeyEntryFormState();
}

class _KeyEntryFormState extends State<_KeyEntryForm> {
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _canSubmit = widget.controller.text.length == BleConstants.pairingKeyLength;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final can = widget.controller.text.length == BleConstants.pairingKeyLength;
    if (can != _canSubmit) setState(() => _canSubmit = can);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Enter pairing key', style: AppTextStyles.h5),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Enter the 6-character key shown on your CCR controller.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          key: PairingScreenKeys.keyField,
          controller: widget.controller,
          enabled: !widget.submitting,
          maxLength: BleConstants.pairingKeyLength,
          style: AppTextStyles.mono,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Pairing Key',
            errorText: widget.errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(
          key: PairingScreenKeys.submitButton,
          onPressed:
              (widget.submitting || !_canSubmit || widget.onSubmit == null)
                  ? null
                  : widget.onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ocean,
            foregroundColor: AppColors.bg,
            disabledBackgroundColor: AppColors.border,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
          ),
          child: widget.submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.bg,
                  ),
                )
              : const Text('Pair Device'),
        ),
      ],
    );
  }
}

class _LockedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, size: 64, color: AppColors.warning),
          const SizedBox(height: AppSpacing.base),
          Text(
            key: PairingScreenKeys.statusText,
            'Device locked out',
            style: AppTextStyles.h5.copyWith(color: AppColors.warning),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Too many wrong attempts. Wait 30 seconds before trying again.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppColors.ocean),
          const SizedBox(height: AppSpacing.base),
          Text(
            key: PairingScreenKeys.statusText,
            'Paired!',
            style: AppTextStyles.h4.copyWith(color: AppColors.ocean),
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.warning),
          const SizedBox(height: AppSpacing.base),
          Text(
            key: PairingScreenKeys.statusText,
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
    );
  }
}
