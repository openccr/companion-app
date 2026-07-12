// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openccr_companion/src/ble/domain/ble_device_info.dart';
import 'package:openccr_companion/src/ble/domain/ble_repository.dart';
import 'package:openccr_companion/src/ble/presentation/ble_providers.dart';

class MockBleRepository extends Mock implements BleRepository {}

final _fakeInfo = BleDeviceInfo(
  protocolVersion: 1,
  firmwareMajor: 1,
  firmwareMinor: 4,
  firmwarePatch: 2,
  serialSuffix: 'TEST',
  modelId: 1,
  flags: 0,
);

void main() {
  late MockBleRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockBleRepository();
    container = ProviderContainer(
      overrides: [bleRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() => container.dispose());

  test('initial state is empty map', () {
    expect(container.read(bleConnectionProvider), isEmpty);
  });

  test('connect sets isConnecting=true synchronously before await', () async {
    when(() => mockRepo.connect(any())).thenAnswer((_) async => _fakeInfo);

    final connectFuture =
        container.read(bleConnectionProvider.notifier).connect('dev-1');

    expect(
      container.read(bleConnectionProvider)['dev-1']?.isConnecting,
      isTrue,
    );

    await connectFuture;
  });

  test('connect clears isConnecting and has no error on success', () async {
    when(() => mockRepo.connect(any())).thenAnswer((_) async => _fakeInfo);

    await container.read(bleConnectionProvider.notifier).connect('dev-1');

    final status = container.read(bleConnectionProvider)['dev-1']!;
    expect(status.isConnecting, isFalse);
    expect(status.error, isNull);
  });

  test('connect sets error and clears isConnecting on failure', () async {
    when(() => mockRepo.connect(any())).thenThrow(Exception('adapter off'));

    await container.read(bleConnectionProvider.notifier).connect('dev-1');

    final status = container.read(bleConnectionProvider)['dev-1']!;
    expect(status.isConnecting, isFalse);
    expect(status.error, contains('adapter off'));
  });

  test('multiple devices tracked independently', () async {
    when(() => mockRepo.connect(any())).thenAnswer((_) async => _fakeInfo);

    await container.read(bleConnectionProvider.notifier).connect('dev-1');
    await container.read(bleConnectionProvider.notifier).connect('dev-2');

    final state = container.read(bleConnectionProvider);
    expect(state.containsKey('dev-1'), isTrue);
    expect(state.containsKey('dev-2'), isTrue);
  });
}
