import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'gooey_switch.dart';
import 'gooey_tab_bar.dart';
import 'gooey_toggle.dart';

class GooeySwitchDemoScreen extends StatefulWidget {
  const GooeySwitchDemoScreen({super.key});

  @override
  State<GooeySwitchDemoScreen> createState() => _GooeySwitchDemoScreenState();
}

class _GooeySwitchDemoScreenState extends State<GooeySwitchDemoScreen>
    with TickerProviderStateMixin {
  bool _value1 = false;
  bool _value2 = true;
  bool _value3 = false;
  bool _valueMaterial = false;
  bool _valueLarge = true;
  bool _valueCustom = false;

  bool _toggleLang = false;
  bool _toggleMode = true;
  bool _toggleDisabled = false;

  late TabController _tabBar2Controller;
  late TabController _tabBar3Controller;

  @override
  void initState() {
    super.initState();
    _tabBar2Controller = TabController(length: 2, vsync: this);
    _tabBar3Controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabBar2Controller.dispose();
    _tabBar3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gooey Switch Demo')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('GooeySwitch', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Default', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _row(
            'Off → On',
            GooeySwitch(
              value: _value1,
              onChanged: (v) => setState(() => _value1 = v),
            ),
          ),
          _row(
            'On → Off',
            GooeySwitch(
              value: _value2,
              onChanged: (v) => setState(() => _value2 = v),
            ),
          ),
          _row(
            'Disabled (off)',
            GooeySwitch(
              value: _value3,
              onChanged: (v) => setState(() => _value3 = v),
              enabled: false,
            ),
          ),
          _row(
            'Disabled (on)',
            GooeySwitch(
              value: true,
              onChanged: (_) {},
              enabled: false,
            ),
          ),
          const SizedBox(height: 32),
          Text('Scaled (1.5x)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _row(
            'Large',
            GooeySwitch(
              value: _valueLarge,
              onChanged: (v) => setState(() => _valueLarge = v),
              scale: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Text('Custom Colors', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _row(
            'Blue active',
            GooeySwitch(
              value: _valueCustom,
              onChanged: (v) => setState(() => _valueCustom = v),
              activeColor: AppColors.info,
              inactiveColor: AppColors.statusErrorBg,
            ),
          ),
          const SizedBox(height: 32),
          Text('vs Material Switch', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _row(
            'Material',
            Switch(
              value: _valueMaterial,
              onChanged: (v) => setState(() => _valueMaterial = v),
            ),
          ),
          _row(
            'Gooey',
            GooeySwitch(
              value: _valueMaterial,
              onChanged: (v) => setState(() => _valueMaterial = v),
            ),
          ),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 24),
          Text('GooeyToggle', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          _row(
            'Language (ES/UA)',
            GooeyToggle(
              value: _toggleLang,
              onChanged: (v) => setState(() => _toggleLang = v),
              leftLabel: 'ES',
              rightLabel: 'UA',
            ),
          ),
          _row(
            'Mode (Day/Night)',
            GooeyToggle(
              value: _toggleMode,
              onChanged: (v) => setState(() => _toggleMode = v),
              leftLabel: 'Day',
              rightLabel: 'Night',
              thumbColor: AppColors.info,
            ),
          ),
          _row(
            'Disabled',
            GooeyToggle(
              value: _toggleDisabled,
              onChanged: (v) => setState(() => _toggleDisabled = v),
              leftLabel: 'A',
              rightLabel: 'B',
              enabled: false,
            ),
          ),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 24),
          Text('GooeyTabBar', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('2 tabs', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          GooeyTabBar(
            controller: _tabBar2Controller,
            labels: const ['Details', 'History'],
          ),
          const SizedBox(height: 24),
          Text('3 tabs + badges', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          GooeyTabBar(
            controller: _tabBar3Controller,
            labels: const ['Requests', 'Plans', 'Users'],
            badges: const [5, 12, null],
            badgeStyles: const [BadgeStyle.success, BadgeStyle.neutral, null],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          trailing,
        ],
      ),
    );
  }
}
