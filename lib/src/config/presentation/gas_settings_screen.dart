// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';

// ── Test keys ─────────────────────────────────────────────────────────────────

abstract final class GasSettingsScreenKeys {
  static const o2Stepper = Key('gas_o2');
  static const heStepper = Key('gas_he');
  static const saveButton = Key('gas_save');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class GasSettingsScreen extends StatefulWidget {
  const GasSettingsScreen({super.key});

  @override
  State<GasSettingsScreen> createState() => _GasSettingsScreenState();
}

class _GasSettingsScreenState extends State<GasSettingsScreen> {
  int _o2 = 21; // 21–100 %
  int _he = 0; // 0–79 %
  int _cons = 1; // 0=Low, 1=Mid, 2=High

  int get _n2 => (100 - _o2 - _he).clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gas Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gas Mix', style: AppTextStyles.h6),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Stepper(
                    key: GasSettingsScreenKeys.o2Stepper,
                    label: 'O₂',
                    value: '$_o2',
                    unit: '%',
                    onDecrement: _o2 > 21 ? () => setState(() => _o2--) : null,
                    onIncrement:
                        _o2 < 100 - _he ? () => setState(() => _o2++) : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Stepper(
                    key: GasSettingsScreenKeys.heStepper,
                    label: 'He',
                    value: '$_he',
                    unit: '%',
                    onDecrement: _he > 0 ? () => setState(() => _he--) : null,
                    onIncrement:
                        _he < 100 - _o2 ? () => setState(() => _he++) : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _Stepper(
                    label: 'N₂',
                    value: '$_n2',
                    unit: '%',
                    readOnly: true,
                    onDecrement: null,
                    onIncrement: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _GasBar(o2: _o2 / 100, he: _he / 100),
            const SizedBox(height: AppSpacing.lg),
            Text('Conservatism', style: AppTextStyles.h6),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Low')),
                  ButtonSegment(value: 1, label: Text('Mid')),
                  ButtonSegment(value: 2, label: Text('High')),
                ],
                selected: {_cons},
                onSelectionChanged: (s) => setState(() => _cons = s.first),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: GasSettingsScreenKeys.saveButton,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  const _Stepper({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.unit,
    this.readOnly = false,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String? unit;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final display = unit != null ? '$value $unit' : value;
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: readOnly
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Center(
                    child: Text(display, style: AppTextStyles.label),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepBtn(icon: Icons.remove, onPressed: onDecrement),
                    Expanded(
                      child: Center(
                        child: Text(display, style: AppTextStyles.label),
                      ),
                    ),
                    _StepBtn(icon: Icons.add, onPressed: onIncrement),
                  ],
                ),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: AppSpacing.base),
      onPressed: onPressed,
      color: onPressed != null ? AppColors.ocean : AppColors.border,
    );
  }
}

class _GasBar extends StatelessWidget {
  const _GasBar({required this.o2, required this.he});

  final double o2;
  final double he;

  @override
  Widget build(BuildContext context) {
    final n2 = (1.0 - o2 - he).clamp(0.0, 1.0);
    final o2i = (o2 * 100).round();
    final hei = (he * 100).round();
    final n2i = (n2 * 100).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        height: AppSpacing.sm,
        child: Row(
          children: [
            if (o2i > 0)
              Expanded(
                flex: o2i,
                child: const ColoredBox(color: AppColors.cyan),
              ),
            if (hei > 0)
              Expanded(
                flex: hei,
                child: const ColoredBox(color: AppColors.ocean),
              ),
            if (n2i > 0)
              Expanded(
                flex: n2i,
                child: const ColoredBox(color: AppColors.border),
              ),
          ],
        ),
      ),
    );
  }
}
