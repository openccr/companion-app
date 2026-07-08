---
name: App bug
about: Report a defect in app display logic, BLE connectivity, or a UI widget
title: '[BUG] '
labels: bug
assignees: ''
---

## Platform

<!-- iOS version or Android API level, e.g.:
     iOS 17.4
     Android API 34 (Android 14) -->

## App Version / Commit

<!-- Build number and full git SHA where the defect was observed -->

## Controller Firmware Version

<!-- Git SHA of the firmware running on the connected openCCR controller -->

## BLE Connection State

<!-- Connection state at the time the bug occurred:
     Connected / Reconnecting / Disconnected -->

## Description

<!-- What is wrong? Be specific: which screen, which widget,
     what was observed vs what was expected. -->

## Safety Impact

<!-- Does this defect affect any of the following?
     - Alarm display (alarm not shown, wrong severity, wrong state)
     - PO₂ readout (wrong value, wrong units, out-of-range not handled)
     - BLE connection state indication (misleading connected/disconnected UI)

     If yes, prefix the issue title with [SAFETY] -->

## Reproduction Steps

<!-- Minimal reproduction: steps to trigger the defect,
     including controller state, BLE state, and any locale/settings involved -->

## Proposed Fix

<!-- If you know the correct logic or fix, describe it here -->

## References

<!-- CCRAN spec sections, BLE GATT profile documentation,
     or other supporting material -->
