# Safety Policy

## This Is a Pre- and Post-Dive Tool

The openCCR companion app is used **before and after dives** — for configuration, calibration, bench testing, log review, and firmware updates. It is not used during a dive and does not function as a dive instrument.

It is:

- **Not a dive instrument** — the app is used out of the water; the CCR controller's own displays are the primary interface during a dive
- **Not approved** by any diving standards body (PADI, IANTD, TDI, DAN, etc.)
- **Not validated** for correctness, safety, or reliability as a life-support instrument
- **Not certified** under any regulatory or medical device framework

Display correctness still matters: incorrect PO₂ readings or alarm thresholds shown during calibration or pre-dive bench testing could lead to a misconfigured system and a dangerous dive.

---

## Reporting App Defects

If you find a defect in app display logic — especially one that could cause a safety-relevant failure such as an alarm not being shown or PO₂ readings being incorrect — report it as an **App bug** using the provided issue template.

Public reporting is essential because every community member who has deployed from this repository needs to know and update their installation.

**Open an App bug issue**: [github.com/openccr/companion-app/issues/new/choose](https://github.com/openccr/companion-app/issues/new/choose)

Select **"App bug"** and use the `[SAFETY]` title prefix for safety-relevant display defects, e.g.:

```
[SAFETY] Alarm state not displayed when BLE reconnects during pre-dive bench test
[SAFETY] PO₂ readings shown with wrong units after locale change
```

Include in your report:

- Platform (iOS version / Android API level)
- App version and git commit SHA
- Controller firmware version (SHA of firmware running on device)
- BLE connection state at time of bug (connected / reconnecting / disconnected)
- Description of the failure mode: which screen, which widget, observed vs expected behaviour
- Reproduction steps
- Proposed fix if known

---

## Responsible Disclosure

For defects where incorrect app behaviour could lead to a misconfigured system or mislead a diver during pre-dive checks, contact the safety team directly before public disclosure:

**Email**: [safety@openccr.org](mailto:safety@openccr.org)

Response timeline:

- **Acknowledge** within 72 hours
- **Fix or mitigation** within 14 days
- **Public disclosure** on the issue tracker following fix/mitigation

---

## Disclaimer

The openCCR project and its contributors provide this app with **no warranty of any kind**. Use is entirely at your own risk. See [LICENSE.md](LICENSE.md) for full terms.
