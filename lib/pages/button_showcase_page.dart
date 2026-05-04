import 'package:flutter/material.dart';
import 'package:spending_tracker/components/ui/cool_button.dart';
import 'package:spending_tracker/utils/color_utils.dart';

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
              'Secondary',
              CoolButton(text: 'Secondary', type: ButtonType.secondary, onPressed: () {}),
            ),
            _buttonRow(
              'Danger',
              CoolButton(text: 'Danger', type: ButtonType.danger, onPressed: () {}),
            ),

            _sectionTitle(context, 'Outlined Variants'),
            _buttonRow(
              'Normal Outline',
              CoolButton(text: 'Normal Outline', outline: true, onPressed: () {}),
            ),
            _buttonRow(
              'Secondary Outline',
              CoolButton(
                text: 'Secondary Outline',
                type: ButtonType.secondary,
                outline: true,
                onPressed: () {},
              ),
            ),

            _sectionTitle(context, 'Neutral Shades'),
            _buttonRow('Black', CoolButton(text: 'Black', bgColor: Colors.black, onPressed: () {})),
            _buttonRow(
              'Black2',
              CoolButton(
                text: 'Black2',
                bgColor: Colors.black,
                onPressed: () {},
                textColor: Colors.teal,
                outline: true,
                baseColor: Colors.grey[900],
              ),
            ),
            _buttonRow(
              'Grey 900',
              CoolButton(text: 'Grey 900', bgColor: Colors.grey[900], onPressed: () {}),
            ),
            _buttonRow(
              'Grey 850',
              CoolButton(text: 'Grey 850', bgColor: Colors.grey[850], onPressed: () {}),
            ),
            _buttonRow(
              'Grey 800',
              CoolButton(text: 'Grey 800', bgColor: Colors.grey[800], onPressed: () {}),
            ),
            _buttonRow(
              'White',
              CoolButton(
                text: 'White',
                bgColor: Colors.white,
                textColor: Colors.black,
                onPressed: () {},
              ),
            ),

            _sectionTitle(context, 'Special Overrides'),
            _buttonRow(
              'Almost Black Teal',
              CoolButton(text: 'Dark Teal', bgColor: const Color(0xFF001A1A), onPressed: () {}),
            ),

            _buttonRow(
              'Almost Black Teal2',
              CoolButton(
                text: 'Dark Teal2',
                bgColor: const Color(0xFF001A1A),
                baseColor: darken(const Color(0xFF001A1A), 25),
                textColor: Colors.teal,
                onPressed: () {},
              ),
            ),
            _buttonRow(
              'Almost Black Teal3',
              CoolButton(
                text: 'Dark Teal3',
                bgColor: const Color(0xFF0D4343),
                baseColor: darken(const Color(0xFF0D4343)),
                textColor: Colors.teal,
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
