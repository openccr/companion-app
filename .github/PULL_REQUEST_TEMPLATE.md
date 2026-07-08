## Summary

<!-- What does this PR change and why? -->

## Affected Features / Platforms

<!-- List the feature area(s) and platform(s) affected by this change,
     e.g., "PO₂ display — iOS and Android" or "BLE reconnection — Android only" -->

## Checklist

### Legal
- [ ] I have read and agree to the [openCCR CLA](../CLA.md)
- [ ] All new files include the correct SPDX license header

### Code Quality
- [ ] `dart format --set-exit-if-changed lib/ test/` passes with zero diffs
- [ ] `flutter analyze` passes with zero warnings or errors
- [ ] `flutter test` passes
- [ ] `flutter build apk` succeeds
- [ ] `flutter build ios --no-codesign` succeeds

### Safety (complete if applicable)
- [ ] Safety impact noted in PR description below (or N/A for non-safety-relevant changes)
- [ ] Changes to alarm display, PO₂ rendering, or BLE reconnection logic reviewed by 2+ contributors (names below)

### Documentation (complete if applicable)
- [ ] dartdoc comments updated for changed public APIs
- [ ] `docs/` updated if app architecture changed

---

## Safety Impact

<!-- Does this change affect any of the following?
     - Alarm display (which alarm states, severity rendering, acknowledgement flow)
     - PO₂ readout accuracy or unit display
     - BLE connection state UI (connected / reconnecting / disconnected indication)
     - OTA update flow

     Describe what was changed and how display correctness is maintained.

     Delete this section if the change is not safety-relevant. -->

## Safety Reviewers

<!-- GitHub usernames of contributors who reviewed this change.
     Required for changes affecting alarm display, PO₂ rendering, or BLE reconnection.
     Delete if not applicable. -->
