import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final strings = controller.strings;
    return ListView(
      key: const Key('settings-page'),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.get('language'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  key: const Key('language-selector'),
                  initialValue: controller.preferences.getString(
                    'manual_locale',
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(strings.get('system')),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text(strings.get('arabic')),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text(strings.get('french')),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(strings.get('english')),
                    ),
                  ],
                  onChanged: controller.setManualLocale,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.get('theme'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: [
                    const ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_suggest_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(strings.get('light')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(strings.get('dark')),
                    ),
                  ],
                  selected: {controller.themeMode},
                  onSelectionChanged: (value) =>
                      controller.setThemeMode(value.first),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.get('currency'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('currency-selector'),
                  initialValue: controller.currency,
                  items:
                      const [
                            'TND',
                            'USD',
                            'EUR',
                            'AED',
                            'SAR',
                            'GBP',
                            'EGP',
                            'MAD',
                          ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) controller.setCurrency(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
