SPDX-License-Identifier: CC-BY-4.0
Copyright (c) 2026 openCCR contributors

# openCCR Companion App — Visual Standards

Design reference for AI-assisted development. All UI work must conform to this document. Source of truth: `openccr.github.io`.

---

## Brand Identity

- Marine × technical aesthetic; professional, open-source, safety-aware
- Dual audience: technical divers and hardware/software developers
- Visual language: precise, minimal, ocean-depth colour palette
- Safety-first: visual hierarchy must never obscure critical alerts

---

## Color Palette

Use as named Flutter `Color` constants. Define in `lib/theme/app_colors.dart`.

| Token | Hex | Flutter constant name | Usage |
|-------|-----|-----------------------|-------|
| `colorBg` | `#FFFFFF` | `AppColors.bg` | Primary background |
| `colorBgSubtle` | `#F0F5FA` | `AppColors.bgSubtle` | Section alternation, subtle fills |
| `colorBorder` | `#C8DCF0` | `AppColors.border` | Borders, dividers |
| `colorText` | `#111827` | `AppColors.text` | Body text |
| `colorTextMuted` | `#4B6478` | `AppColors.textMuted` | Secondary text, captions |
| `colorNavy` | `#0A3060` | `AppColors.navy` | Primary brand — headers, nav, primary buttons |
| `colorOcean` | `#0E6BAD` | `AppColors.ocean` | Links, icons, active states |
| `colorCyan` | `#24B4D8` | `AppColors.cyan` | Focus/hover states, CTAs, interactive highlights |
| `colorWarning` | `#C0392B` | `AppColors.warning` | **SAFETY-CRITICAL ONLY** |

> **CRITICAL RULE:** `colorWarning` (`#C0392B`) is reserved exclusively for life-safety content: CCR alarms, PO₂ alerts, BLE disconnection warnings that could affect diver safety. Do NOT use it for general UI errors, validation messages, or decorative purposes. Misuse of the warning colour is a safety violation.

---

## Typography

Use the `google_fonts` Flutter package. Define in `lib/theme/app_text_styles.dart`.

### Font Families

| Role | Font | Weights | Usage |
|------|------|---------|-------|
| Heading | Space Grotesk | 400, 500, 600, 700 | All titles, section labels, badge text |
| Body | Inter | 400, 500, 600 | Body copy, descriptions, navigation labels |
| Monospace | JetBrains Mono | 400, 500 | Sensor values, hex addresses, BLE UUIDs, firmware output |

### Size Scale

Base unit: 16px (logical pixels / `sp` in Flutter).

| Name | Size |
|------|------|
| xs | 12px |
| sm | 14px |
| base | 16px |
| lg | 18px |
| xl | 20px |
| 2xl | 24px |
| 3xl | 30px |
| 4xl | 36px |
| 5xl | 48px |

### Heading Style Rules

- Color: `colorNavy`
- Line-height: 1.2 (`height: 1.2` in Flutter `TextStyle`)
- Weight: 700 (`FontWeight.w700`)
- Font: Space Grotesk

---

## Spacing Scale

All spacing from a 4px base unit. No arbitrary pixel values — use only these named steps.

| Name | Value |
|------|-------|
| xs | 4px |
| sm | 8px |
| md | 12px |
| base | 16px |
| lg | 24px |
| xl | 32px |
| 2xl | 48px |
| 3xl | 64px |

Define as constants in `lib/theme/app_spacing.dart`.

---

## Border Radius

| Name | Value | Usage |
|------|-------|-------|
| sm | 4px | Tags, small chips |
| md | 8px | Buttons, inputs, text fields |
| lg | 12px | Cards, panels, bottom sheets |
| pill | 100px | Badges, status chips |

---

## Shadows

All shadows use navy-tinted colour. Use Flutter `Color` with alpha prefix notation: `Color(0xAA0A3060)` where `AA` is the hex alpha byte.

| Name | Value | Usage |
|------|-------|-------|
| sm | `BoxShadow(color: Color(0x140A3060), blurRadius: 3, offset: Offset(0, 1))` | Card default |
| md | `BoxShadow(color: Color(0x1F0A3060), blurRadius: 12, offset: Offset(0, 4))` | Card hover, elevated panels |
| lg | `BoxShadow(color: Color(0x290A3060), blurRadius: 24, offset: Offset(0, 8))` | Modals, dialogs |

---

## Component Patterns

### Buttons

**Primary button:**
- Background: `colorNavy`
- Text: white, Inter 500, 16px
- Border radius: 8px (md)
- Press state: background darkens to `Color(0xFF062040)`

**Outline button:**
- Background: transparent
- Border: 1px solid `colorNavy`
- Text: `colorNavy`
- Press state: background fills `colorNavy`, text turns white

**Destructive / light outline (on dark backgrounds):**
- Border: 1px solid white
- Text: white
- Press state: background fills white at 10% opacity

### Cards

- Background: white (`colorBg`)
- Border: 1px solid `colorBorder`
- Border radius: 12px (lg)
- Shadow: shadow-sm (default), shadow-md (hover/press)
- Press/hover animation: shadow-md + `Transform.translate(offset: Offset(0, -2))`

**Card icon area:**
- Size: 48×48px
- Background: `colorBgSubtle`
- Icon color: `colorOcean`
- Border radius: 8px (md)

### Badges

- Shape: pill (100px border radius)
- Font: Space Grotesk, 12px, weight 600, uppercase
- Padding: 4px 10px

| Variant | Background | Text color |
|---------|------------|------------|
| navy | `colorNavy` | white |
| ocean | `colorOcean` at 15% opacity | `colorOcean` |
| cyan | `colorCyan` at 15% opacity | `colorCyan` |
| warning | `colorWarning` at 10% opacity | `colorWarning` — **safety only** |

### Safety Warnings

Used for: PO₂ alerts, CCR alarm display, BLE disconnection with safety implications.

- Border: 2px solid `colorWarning`
- Background: `colorWarning` at 5% opacity (`Color(0x0DC0392B)`)
- Must use a dedicated `SafetyWarning` widget — never use generic `SnackBar` or `AlertDialog` for life-safety notices
- Text: Inter 500, `colorWarning`
- Icon: warning triangle, `colorWarning`, `semanticsLabel` required

### Navigation Bar

- Position: fixed top
- Height: 64px
- Background: white
- Bottom border: 1px solid `colorBorder`
- Brand wordmark: "open" (Inter weight 400, `colorNavy`) + "CCR" (Inter weight 700, `colorNavy`)

### Page Structure

- Max content width: 1200px (tablet/desktop)
- Responsive breakpoint: 768px (tablet → phone layout)
- Section padding: 64px (desktop / landscape tablet), 48px (mobile)

### Hero Areas

**Light hero (main screens):**
- Background: `colorBgSubtle` (`#F0F5FA`)
- Decorative grid overlay: 48×48px crosshatch, `colorOcean` at 6% opacity

**Dark hero (sub-pages, settings headers):**
- Background: `colorNavy`
- Decorative grid overlay: 48×48px crosshatch, white at 3% opacity
- Text: white

---

## Geometric Grid Overlay

Recurring decorative motif on hero sections. Crosshatch grid, 48×48px cell size.

- Light background: `colorOcean` at 6% opacity (`Color(0x0F0E6BAD)`)
- Dark background: white at 3% opacity (`Color(0x08FFFFFF)`)

Flutter implementation: use `CustomPaint` with a `CustomPainter` that draws the grid, or `ShaderMask`. Do not use image assets for this motif.

---

## Accessibility

- All interactive elements: 3px focus outline, `colorCyan`
- Decorative icons: `excludeFromSemantics: true`
- Functional icons: `Semantics(label: '...')` wrapper required
- Color contrast: `colorNavy` on white exceeds WCAG AA (contrast ratio ≥ 4.5:1)
- All navigation and action elements: explicit `semanticsLabel` or `Semantics` widget
- Safety warning widgets: always include accessible label describing the alert condition

---

## Flutter Theme Integration

Define a central `AppTheme` in `lib/theme/app_theme.dart` using `ThemeData`. Token files:

| File | Contents |
|------|----------|
| `lib/theme/app_colors.dart` | `AppColors` class with all `Color` constants |
| `lib/theme/app_text_styles.dart` | `AppTextStyles` class with `TextStyle` constants |
| `lib/theme/app_spacing.dart` | `AppSpacing` class with `double` constants |
| `lib/theme/app_theme.dart` | `AppTheme.light()` returning `ThemeData` |

Do not hardcode colours, font sizes, or spacing values in widget files. Always reference the token classes.
