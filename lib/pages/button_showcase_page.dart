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
            _buttonRow('Normal', CoolButton(text: 'Normal', onPressed: () {})),
            _buttonRow(
              'Normal with Outline',
              CoolButton(text: 'Normal Outline', outline: true, onPressed: () {}),
            ),
            _buttonRow(
              'Danger',
              CoolButton(text: 'Danger', type: ButtonType.danger, onPressed: () {}),
            ),
            _buttonRow(
              'Danger with Outline',
              CoolButton(
                text: 'Danger Outline',
                type: ButtonType.danger,
                outline: true,
                onPressed: () {},
              ),
            ),

            _sectionTitle(context, 'Custom Colors'),
            _buttonRow(
              'Purple',
              CoolButton(text: 'Purple', bgColor: Colors.purple, onPressed: () {}),
            ),
            _buttonRow(
              'Purple with Outline',
              CoolButton(
                text: 'Purple Outline',
                bgColor: Colors.purple,
                outline: true,
                onPressed: () {},
              ),
            ),
            _buttonRow(
              'Amber',
              CoolButton(
                text: 'Amber',
                bgColor: Colors.amber,
                textColor: Colors.black,
                onPressed: () {},
              ),
            ),
            _buttonRow(
              'Custom Base Color',
              CoolButton(
                text: 'Teal Face, Blue Base',
                bgColor: Colors.teal,
                baseColor: Colors.blue[900],
                onPressed: () {},
              ),
            ),

            _sectionTitle(context, 'Disabled States'),
            _buttonRow('Disabled', const CoolButton(text: 'Disabled', onPressed: null)),
            _buttonRow(
              'Disabled with Outline',
              const CoolButton(text: 'Disabled Outline', outline: true, onPressed: null),
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
