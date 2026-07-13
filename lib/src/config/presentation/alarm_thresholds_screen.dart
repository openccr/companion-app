// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:openccr_companion/shared/theme/app_colors.dart';
import 'package:openccr_companion/shared/theme/app_spacing.dart';
import 'package:openccr_companion/shared/theme/app_text_styles.dart';

// ── Test keys ─────────────────────────────────────────────────────────────────

abstract final class AlarmThresholdsScreenKeys {
  static const highPo2Section = Key('alarm_high_po2');
  static const lowPo2Section = Key('alarm_low_po2');
  static const scrubberSection = Key('alarm_scrubber');
  static const co2Section = Key('alarm_co2');
  static const saveButton = Key('alarm_save');
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AlarmThresholdsScreen extends StatefulWidget {
  const AlarmThresholdsScreen({super.key});

  @override
  State<AlarmThresholdsScreen> createState() => _AlarmThresholdsScreenState();
}

class _AlarmThresholdsScreenState extends State<AlarmThresholdsScreen> {
  // High PO₂  range 0.5–2.0 bar  (span 1.5)
  double _hiWarn = 1.45;
  double _hiAlarm = 1.60;

  // Low PO₂   range 0.1–0.5 bar  (span 0.4) — inverted: alarm < warn
  double _loAlarm = 0.19;
  double _loWarn = 0.25;

  // Scrubber   range 20–80 °C    (span 60)
  int _scrubWarn = 55;
  int _scrubAlarm = 65;

  // CO₂        range 0–5000 ppm  (span 5000)
  int _co2Warn = 1000;
  int _co2Alarm = 2000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm Thresholds')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          _AlarmSection(
            key: AlarmThresholdsScreenKeys.highPo2Section,
            title: 'High PO₂',
            safeFrac: (_hiWarn - 0.5) / 1.5,
            warnFrac: (_hiAlarm - _hiWarn) / 1.5,
            warnLabel: '${_hiWarn.toStringAsFixed(2)} bar',
            alarmLabel: '${_hiAlarm.toStringAsFixed(2)} bar',
            rows: [
              _ThresholdRow(
                label: 'Warning',
                value: '${_hiWarn.toStringAsFixed(2)} bar',
                onDecrement: _hiWarn > 0.551
                    ? () => setState(() => _hiWarn =
                        double.parse((_hiWarn - 0.05).toStringAsFixed(2)))
                    : null,
                onIncrement: _hiWarn < _hiAlarm - 0.051
                    ? () => setState(() => _hiWarn =
                        double.parse((_hiWarn + 0.05).toStringAsFixed(2)))
                    : null,
              ),
              _ThresholdRow(
                label: 'Alarm',
                value: '${_hiAlarm.toStringAsFixed(2)} bar',
                onDecrement: _hiAlarm > _hiWarn + 0.051
                    ? () => setState(() => _hiAlarm =
                        double.parse((_hiAlarm - 0.05).toStringAsFixed(2)))
                    : null,
                onIncrement: _hiAlarm < 1.951
                    ? () => setState(() => _hiAlarm =
                        double.parse((_hiAlarm + 0.05).toStringAsFixed(2)))
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _AlarmSection(
            key: AlarmThresholdsScreenKeys.lowPo2Section,
            title: 'Low PO₂',
            safeFrac: (_loAlarm - 0.1) / 0.4,
            warnFrac: (_loWarn - _loAlarm) / 0.4,
            warnLabel: '${_loWarn.toStringAsFixed(2)} bar',
            alarmLabel: '${_loAlarm.toStringAsFixed(2)} bar',
            inverted: true,
            rows: [
              _ThresholdRow(
                label: 'Alarm',
                value: '${_loAlarm.toStringAsFixed(2)} bar',
                onDecrement: _loAlarm > 0.111
                    ? () => setState(() => _loAlarm =
                        double.parse((_loAlarm - 0.01).toStringAsFixed(2)))
                    : null,
                onIncrement: _loAlarm < _loWarn - 0.011
                    ? () => setState(() => _loAlarm =
                        double.parse((_loAlarm + 0.01).toStringAsFixed(2)))
                    : null,
              ),
              _ThresholdRow(
                label: 'Warning',
                value: '${_loWarn.toStringAsFixed(2)} bar',
                onDecrement: _loWarn > _loAlarm + 0.011
                    ? () => setState(() => _loWarn =
                        double.parse((_loWarn - 0.01).toStringAsFixed(2)))
                    : null,
                onIncrement: _loWarn < 0.491
                    ? () => setState(() => _loWarn =
                        double.parse((_loWarn + 0.01).toStringAsFixed(2)))
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _AlarmSection(
            key: AlarmThresholdsScreenKeys.scrubberSection,
            title: 'Scrubber Temp',
            safeFrac: (_scrubWarn - 20) / 60,
            warnFrac: (_scrubAlarm - _scrubWarn) / 60,
            warnLabel: '$_scrubWarn °C',
            alarmLabel: '$_scrubAlarm °C',
            rows: [
              _ThresholdRow(
                label: 'Warning',
                value: '$_scrubWarn °C',
                onDecrement:
                    _scrubWarn > 21 ? () => setState(() => _scrubWarn--) : null,
                onIncrement: _scrubWarn < _scrubAlarm - 1
                    ? () => setState(() => _scrubWarn++)
                    : null,
              ),
              _ThresholdRow(
                label: 'Alarm',
                value: '$_scrubAlarm °C',
                onDecrement: _scrubAlarm > _scrubWarn + 1
                    ? () => setState(() => _scrubAlarm--)
                    : null,
                onIncrement: _scrubAlarm < 79
                    ? () => setState(() => _scrubAlarm++)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          _AlarmSection(
            key: AlarmThresholdsScreenKeys.co2Section,
            title: 'CO₂',
            safeFrac: _co2Warn / 5000,
            warnFrac: (_co2Alarm - _co2Warn) / 5000,
            warnLabel: '$_co2Warn ppm',
            alarmLabel: '$_co2Alarm ppm',
            rows: [
              _ThresholdRow(
                label: 'Warning',
                value: '$_co2Warn ppm',
                onDecrement: _co2Warn > 100
                    ? () => setState(() => _co2Warn -= 100)
                    : null,
                onIncrement: _co2Warn < _co2Alarm - 100
                    ? () => setState(() => _co2Warn += 100)
                    : null,
              ),
              _ThresholdRow(
                label: 'Alarm',
                value: '$_co2Alarm ppm',
                onDecrement: _co2Alarm > _co2Warn + 100
                    ? () => setState(() => _co2Alarm -= 100)
                    : null,
                onIncrement: _co2Alarm < 4900
                    ? () => setState(() => _co2Alarm += 100)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: AlarmThresholdsScreenKeys.saveButton,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _AlarmSection extends StatelessWidget {
  const _AlarmSection({
    super.key,
    required this.title,
    required this.safeFrac,
    required this.warnFrac,
    required this.warnLabel,
    required this.alarmLabel,
    required this.rows,
    this.inverted = false,
  });

  final String title;
  final double safeFrac;
  final double warnFrac;
  final String warnLabel;
  final String alarmLabel;
  final List<Widget> rows;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final alarmFrac = (1.0 - safeFrac - warnFrac).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            _ThresholdBar(
              safeFrac: safeFrac,
              warnFrac: warnFrac,
              alarmFrac: alarmFrac,
              warnLabel: warnLabel,
              alarmLabel: alarmLabel,
              inverted: inverted,
            ),
            const SizedBox(height: AppSpacing.md),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _ThresholdBar extends StatelessWidget {
  const _ThresholdBar({
    required this.safeFrac,
    required this.warnFrac,
    required this.alarmFrac,
    required this.warnLabel,
    required this.alarmLabel,
    this.inverted = false,
  });

  final double safeFrac;
  final double warnFrac;
  final double alarmFrac;
  final String warnLabel;
  final String alarmLabel;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final si = (safeFrac * 100).round().clamp(0, 100);
    final wi = (warnFrac * 100).round().clamp(0, 100);
    final ai = (alarmFrac * 100).round().clamp(0, 100);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: SizedBox(
            height: 12,
            child: Row(
              children: inverted
                  ? [
                      if (ai > 0)
                        Expanded(
                          flex: ai,
                          child: const ColoredBox(color: AppColors.warning),
                        ),
                      if (wi > 0)
                        Expanded(
                          flex: wi,
                          child: const ColoredBox(color: AppColors.caution),
                        ),
                      if (si > 0)
                        Expanded(
                          flex: si,
                          child: const ColoredBox(color: AppColors.safe),
                        ),
                    ]
                  : [
                      if (si > 0)
                        Expanded(
                          flex: si,
                          child: const ColoredBox(color: AppColors.safe),
                        ),
                      if (wi > 0)
                        Expanded(
                          flex: wi,
                          child: const ColoredBox(color: AppColors.caution),
                        ),
                      if (ai > 0)
                        Expanded(
                          flex: ai,
                          child: const ColoredBox(color: AppColors.warning),
                        ),
                    ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Pin(
              label: inverted ? 'A: $alarmLabel' : 'W: $warnLabel',
              color: inverted ? AppColors.warning : AppColors.caution,
            ),
            _Pin(
              label: inverted ? 'W: $warnLabel' : 'A: $alarmLabel',
              color: inverted ? AppColors.caution : AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: AppSpacing.xs),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }
}

class _ThresholdRow extends StatelessWidget {
  const _ThresholdRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });
  final String label;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  _StepBtn(icon: Icons.remove, onPressed: onDecrement),
                  Expanded(
                    child: Center(
                      child: Text(value, style: AppTextStyles.label),
                    ),
                  ),
                  _StepBtn(icon: Icons.add, onPressed: onIncrement),
                ],
              ),
            ),
          ),
        ],
      ),
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
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      color: onPressed != null ? AppColors.ocean : AppColors.border,
    );
  }
}
