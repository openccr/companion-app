// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';

// ── Value tables ──────────────────────────────────────────────────────────────

List<double> _range(double lo, double hi, double step) {
  final out = <double>[];
  var v = lo;
  while (v <= hi + step * 0.001) {
    out.add(double.parse(v.toStringAsFixed(2)));
    v += step;
  }
  return out;
}

final _constSpValues = _range(0.50, 1.60, 0.05);
final _hiSpValues = _range(0.70, 1.60, 0.05);
final _loSpValues = _range(0.30, 1.00, 0.05);
final _surfSpValues = _range(0.15, 0.30, 0.01);

// ── Test keys ─────────────────────────────────────────────────────────────────

abstract final class DiveSettingsScreenKeys {
  static const setpointModeToggle = Key('dive_setpoint_mode');
  static const constantSpPicker = Key('dive_const_sp');
  static const hiSpPicker = Key('dive_hi_sp');
  static const loSpPicker = Key('dive_lo_sp');
  static const surfSpPicker = Key('dive_surf_sp');
  static const gfDisplay = Key('dive_gf_display');
  static const gfLowStepper = Key('dive_gf_low');
  static const gfHighStepper = Key('dive_gf_high');
  static const penaliseToggle = Key('dive_penalise');
  static const saveButton = Key('dive_save');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class DiveSettingsScreen extends StatefulWidget {
  const DiveSettingsScreen({super.key});

  @override
  State<DiveSettingsScreen> createState() => _DiveSettingsScreenState();
}

class _DiveSettingsScreenState extends State<DiveSettingsScreen> {
  bool _hiLowMode = false;
  int _constSpIdx = _constSpValues.indexOf(0.60);
  int _hiSpIdx = _hiSpValues.indexOf(1.30);
  int _loSpIdx = _loSpValues.indexOf(0.70);
  int _surfSpIdx = _surfSpValues.indexOf(0.18);
  int _gfLow = 35;
  int _gfHigh = 75;
  bool _penalise = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dive Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          Text('Setpoint', style: AppTextStyles.h6),
          const SizedBox(height: AppSpacing.md),
          _SetpointCard(
            hiLowMode: _hiLowMode,
            constSpIdx: _constSpIdx,
            hiSpIdx: _hiSpIdx,
            loSpIdx: _loSpIdx,
            surfSpIdx: _surfSpIdx,
            onModeChanged: (v) => setState(() => _hiLowMode = v),
            onConstSpChanged: (i) => setState(() => _constSpIdx = i),
            onHiSpChanged: (i) {
              if (_hiSpValues[i] > _loSpValues[_loSpIdx]) {
                setState(() => _hiSpIdx = i);
              }
            },
            onLoSpChanged: (i) {
              if (_loSpValues[i] < _hiSpValues[_hiSpIdx]) {
                setState(() => _loSpIdx = i);
              }
            },
            onSurfSpChanged: (i) => setState(() => _surfSpIdx = i),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Gradient Factors', style: AppTextStyles.h6),
          const SizedBox(height: AppSpacing.md),
          _GfCard(
            gfLow: _gfLow,
            gfHigh: _gfHigh,
            penalise: _penalise,
            onGfLowChanged: (v) {
              if (v >= 1 && v <= 110) setState(() => _gfLow = v);
            },
            onGfHighChanged: (v) {
              if (v >= 1 && v <= 110) setState(() => _gfHigh = v);
            },
            onPenaliseChanged: (v) => setState(() => _penalise = v),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: DiveSettingsScreenKeys.saveButton,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Setpoint card ─────────────────────────────────────────────────────────────

class _SetpointCard extends StatelessWidget {
  const _SetpointCard({
    required this.hiLowMode,
    required this.constSpIdx,
    required this.hiSpIdx,
    required this.loSpIdx,
    required this.surfSpIdx,
    required this.onModeChanged,
    required this.onConstSpChanged,
    required this.onHiSpChanged,
    required this.onLoSpChanged,
    required this.onSurfSpChanged,
  });

  final bool hiLowMode;
  final int constSpIdx;
  final int hiSpIdx;
  final int loSpIdx;
  final int surfSpIdx;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<int> onConstSpChanged;
  final ValueChanged<int> onHiSpChanged;
  final ValueChanged<int> onLoSpChanged;
  final ValueChanged<int> onSurfSpChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hiLowMode ? 'Hi/Low Setpoint' : 'Constant Setpoint',
                    style: AppTextStyles.body,
                  ),
                ),
                Switch.adaptive(
                  key: DiveSettingsScreenKeys.setpointModeToggle,
                  value: hiLowMode,
                  onChanged: onModeChanged,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!hiLowMode)
              Center(
                child: _WheelPicker(
                  pickerKey: DiveSettingsScreenKeys.constantSpPicker,
                  values: _constSpValues,
                  selectedIndex: constSpIdx,
                  onChanged: onConstSpChanged,
                  label: 'Setpoint (ata)',
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _WheelPicker(
                    pickerKey: DiveSettingsScreenKeys.loSpPicker,
                    values: _loSpValues,
                    selectedIndex: loSpIdx,
                    onChanged: onLoSpChanged,
                    label: 'Low (ata)',
                  ),
                  _WheelPicker(
                    pickerKey: DiveSettingsScreenKeys.hiSpPicker,
                    values: _hiSpValues,
                    selectedIndex: hiSpIdx,
                    onChanged: onHiSpChanged,
                    label: 'High (ata)',
                  ),
                ],
              ),
            const Divider(height: AppSpacing.xl),
            Center(
              child: _WheelPicker(
                pickerKey: DiveSettingsScreenKeys.surfSpPicker,
                values: _surfSpValues,
                selectedIndex: surfSpIdx,
                onChanged: onSurfSpChanged,
                label: 'Surface setpoint (ata)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GF card ───────────────────────────────────────────────────────────────────

class _GfCard extends StatelessWidget {
  const _GfCard({
    required this.gfLow,
    required this.gfHigh,
    required this.penalise,
    required this.onGfLowChanged,
    required this.onGfHighChanged,
    required this.onPenaliseChanged,
  });

  final int gfLow;
  final int gfHigh;
  final bool penalise;
  final ValueChanged<int> onGfLowChanged;
  final ValueChanged<int> onGfHighChanged;
  final ValueChanged<bool> onPenaliseChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'GF $gfLow/$gfHigh',
                key: DiveSettingsScreenKeys.gfDisplay,
                style: AppTextStyles.h6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GfStepper(
                  key: DiveSettingsScreenKeys.gfLowStepper,
                  label: 'GF Low',
                  value: gfLow,
                  onDecrement:
                      gfLow > 1 ? () => onGfLowChanged(gfLow - 1) : null,
                  onIncrement:
                      gfLow < 110 ? () => onGfLowChanged(gfLow + 1) : null,
                ),
                _GfStepper(
                  key: DiveSettingsScreenKeys.gfHighStepper,
                  label: 'GF High',
                  value: gfHigh,
                  onDecrement:
                      gfHigh > 1 ? () => onGfHighChanged(gfHigh - 1) : null,
                  onIncrement:
                      gfHigh < 110 ? () => onGfHighChanged(gfHigh + 1) : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile.adaptive(
              key: DiveSettingsScreenKeys.penaliseToggle,
              value: penalise,
              onChanged: onPenaliseChanged,
              title: const Text('Penalise high ascent rate'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _WheelPicker extends StatefulWidget {
  const _WheelPicker({
    required this.pickerKey,
    required this.values,
    required this.selectedIndex,
    required this.onChanged,
    this.label,
  });

  final Key pickerKey;
  final List<double> values;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String? label;

  @override
  State<_WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<_WheelPicker> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        FixedExtentScrollController(initialItem: widget.selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelSm,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        SizedBox(
          height: AppSpacing.xxl * 2,
          width: AppSpacing.xxl * 1.5,
          child: CupertinoPicker(
            key: widget.pickerKey,
            scrollController: _controller,
            itemExtent: AppSpacing.xl,
            onSelectedItemChanged: widget.onChanged,
            children: [
              for (final v in widget.values)
                Center(
                  child: Text(
                    v.toStringAsFixed(2),
                    style: AppTextStyles.monoSm,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GfStepper extends StatelessWidget {
  const _GfStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm,
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepBtn(icon: Icons.remove, onPressed: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('$value', style: AppTextStyles.label),
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
