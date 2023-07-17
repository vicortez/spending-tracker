import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text("Spending tracker"),
        SizedBox(
          height: 10,
        ),
        Text("Developed by Victor Cortez using Flutter"),
        InkWell(onTap: _launchURL, child: Text(style: TextStyle(color: Colors.blue), "https://github.com/vicortez")),
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
