import 'package:flutter/material.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';

class ButtonShowcasePage extends StatelessWidget {
  const ButtonShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Button Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'Theme Defaults'),
            _buttonRow('Normal', const CoolButton(text: 'Normal')),
            _buttonRow('Normal Outline', const CoolButton(text: 'Normal Outline', isOutline: true)),
            _buttonRow('Danger', const CoolButton(text: 'Danger', type: ButtonType.danger)),
            _buttonRow(
              'Danger Outline',
              const CoolButton(text: 'Danger Outline', type: ButtonType.danger, isOutline: true),
            ),

            _sectionTitle(context, 'Custom Colors'),
            _buttonRow('Purple', const CoolButton(text: 'Purple', bgColor: Colors.purple)),
            _buttonRow(
              'Purple Outline',
              const CoolButton(text: 'Purple Outline', bgColor: Colors.purple, isOutline: true),
            ),
            _buttonRow(
              'Amber',
              const CoolButton(text: 'Amber', bgColor: Colors.amber, textColor: Colors.black),
            ),
            _buttonRow(
              'Amber Outline',
              const CoolButton(text: 'Amber Outline', bgColor: Colors.amber, isOutline: true),
            ),

            _sectionTitle(context, 'Disabled States'),
            _buttonRow('Disabled', const CoolButton(text: 'Disabled', onPressed: null)),
            _buttonRow(
              'Disabled Outline',
              const CoolButton(text: 'Disabled Outline', isOutline: true, onPressed: null),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buttonRow(String label, Widget button) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          button,
        ],
      ),
    );
  }
}
