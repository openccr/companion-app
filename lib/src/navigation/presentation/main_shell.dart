// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (c) 2026 openCCR contributors

import 'package:flutter/material.dart';
import 'package:openccr_companion/src/config/presentation/config_screen.dart';
import 'package:openccr_companion/src/devices/presentation/devices_screen.dart';
import 'package:openccr_companion/src/live/presentation/live_picker_screen.dart';
import 'package:openccr_companion/src/logs/presentation/logs_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Devices', 'Config', 'Live', 'Logs'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: _index == 3
            ? [
                IconButton(
                  icon: const Icon(Icons.upload_outlined),
                  tooltip: 'Export all',
                  onPressed: null,
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          DevicesScreen(),
          ConfigScreen(),
          LivePickerScreen(),
          LogsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bluetooth_outlined),
            selectedIcon: Icon(Icons.bluetooth),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Config',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Live',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Logs',
          ),
        ],
      ),
    );
  }
}
