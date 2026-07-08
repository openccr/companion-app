# Testing

## Targets

| Type | Share |
|------|-------|
| Unit | ~60% |
| Widget | ~25% |
| Integration | ~10% |

## File Location

Mirror `lib/` under `test/`:
- Unit: `test/src/<feature>/domain/`, `test/src/<feature>/data/`
- Widget: `test/src/<feature>/presentation/`

## Rules

**Structure**: Arrange / Act / Assert. One logical assertion per test. `setUp`/`tearDown` for shared fixtures.

**Naming**: `methodName_givenCondition_expectedResult` or a natural English sentence.

**Mocking**: Use `mocktail`. Mock at repository boundary (domain interfaces). Never mock platform channels directly — wrap in abstraction first, mock the abstraction.

**Widget tests**:
- Wrap in `MaterialApp` (or `ProviderScope` for Riverpod)
- `Key` constants defined in widget file — use for lookup, not text strings
- Test loading, error, and populated states explicitly
- `tester.pump(duration)` / `tester.pumpAndSettle()` for async transitions

## Required Edge-Case Coverage

Safety-critical — all cases must have tests:

| Area | Required cases |
|------|---------------|
| Alarm rendering | Each severity level; empty/no-alarm state; multiple simultaneous alarms |
| PO₂ display | Normal range; high boundary; low boundary; null/missing data |
| BLE connection | Connected; reconnecting; disconnected; failed |
