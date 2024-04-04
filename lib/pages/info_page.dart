import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spending_tracker/pages/experimental_page.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Spending tracker"),
        const SizedBox(
          height: 10,
        ),
        const Text("Developed by Victor Cortez using Flutter"),
        const InkWell(
            onTap: _launchURL, child: Text(style: TextStyle(color: Colors.blue), "https://github.com/vicortez")),
        const Expanded(child: SizedBox.shrink()),
        RichText(
          text: TextSpan(
            text: '',
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: 'Open experimental features page',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Perform your action here
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TestPage()),
                    );
                  },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text("Version 0.21.0"),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}

_launchURL() async {
  const url = 'https://github.com/vicortez';
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}
