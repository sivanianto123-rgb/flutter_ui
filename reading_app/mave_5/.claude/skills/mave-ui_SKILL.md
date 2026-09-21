---
name: mave-ui
description: Mave app design system. Auto-load for any Flutter UI, widget,
  screen, or animation work. Covers color tokens, typography, Sprout mascot
  rules, spacing, and component patterns.
---

# Mave Design System

## Brand Colors (use as Flutter Color hex)
```dart
// Primary palette
const maOrange   = Color(0xFFFF8F40); // CTAs, highlights
const maSand     = Color(0xFFF5C97A); // background warm
const maSandDark = Color(0xFFE8A84C); // gradient bottom
const maSky      = Color(0xFF87CEEB); // sky backgrounds
const maText     = Color(0xFF3D2C1E); // primary text
const maTextMid  = Color(0xFF7A5C3A); // secondary text
const maTextMuted= Color(0xFFB09060); // hints / labels

// Zone colors
const maPhonicsBlue  = Color(0xFF5BBFFA);
const maWordGreen    = Color(0xFF81C784);
const maSentencePurp = Color(0xFF9C5FD6);

// Bubble accent colors (for phonics bubbles)
const maBubble1 = Color(0xFF5BBFFA);
const maBubble2 = Color(0xFFFF8FA0);
const maBubble3 = Color(0xFFA78BFA);
const maBubble4 = Color(0xFF4ADE80);
```

## Typography
- Display / titles: **Fredoka One** (Google Fonts)
- Body / labels: **Nunito** weights 400, 600, 700, 800

```dart
// Title style
TextStyle maTitleStyle = GoogleFonts.fredokaOne(
  fontSize: 42, color: maOrange,
  shadows: [Shadow(color: Color(0x33B45000), offset: Offset(0,3))],
);
// Body
TextStyle maBodyStyle = GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: maText);
// Label muted
TextStyle maLabelStyle = GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: maTextMuted);
```

## Sprout Mascot Rules
- Sprout is a small friendly plant-creature with round eyes and leaf ears
- Always appears in encouraging, non-threatening poses
- Never used during error states — use gentle shake animations instead
- Rendered via Rive animation file: `assets/rive/sprout.riv`
- States: idle, celebrate, thinking, wave
- Size: 80–120px depending on screen context

## Spacing System
```
xs: 4px   sm: 8px   md: 16px   lg: 24px   xl: 40px
```

## Border Radius
```
bubble: 999px (circle)   card: 24px   button: 50px   input: 16px
```

## Shadows
```dart
// Card shadow
BoxShadow(color: Color(0x20000000), blurRadius: 16, offset: Offset(0,6))
// Button press shadow
BoxShadow(color: Color(0xFF...).withOpacity(.3), blurRadius: 10, offset: Offset(0,4))
```

## Screen Background Gradient
```dart
LinearGradient(
  begin: Alignment.topCenter, end: Alignment.bottomCenter,
  colors: [Color(0xFFFFF1D0), Color(0xFFFFE0A3), Color(0xFFF5C97A), Color(0xFFE8A84C)],
  stops: [0.0, 0.4, 0.7, 1.0],
)
```

## Component Checklist (every screen)
- [ ] Gradient background applied
- [ ] Fredoka One used for all headings / zone names / level numbers
- [ ] Nunito used for all body text / labels
- [ ] Tap targets ≥ 44×44px (toddler-safe)
- [ ] No text below 14sp on primary content
- [ ] Bouncy entry animations (Curves.elasticOut) on interactive elements
- [ ] Sound feedback on every tap (use SoundManager)
