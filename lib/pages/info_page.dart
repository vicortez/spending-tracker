import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spending_tracker/pages/test_page.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Spending tracker"),
        SizedBox(
          height: 10,
        ),
        Text("Developed by Victor Cortez using Flutter"),
        InkWell(onTap: _launchURL, child: Text(style: TextStyle(color: Colors.blue), "https://github.com/vicortez")),
        Expanded(child: SizedBox.shrink()),
        RichText(
          text: TextSpan(
            text: '',
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: 'Version 0.18.0',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Perform your action here
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TestPage()),
                    );
                  },
              ),
            ],
          ),
        ),
        SizedBox(
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
