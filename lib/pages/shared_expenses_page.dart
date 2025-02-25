// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:spending_tracker/pages/experimental_page.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class SharedExpensesPage extends StatelessWidget {
//   const SharedExpensesPage({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Text("Shared expenses"),
//         const SizedBox(
//           height: 10,
//         ),
//         IconButton.outlined(
//             onPressed: () async {
//               var a = await fetchAlbum();
//               print(a.statusCode);
//               print(a);
//               // fetchAlbum(). .then((value) => (value) {
//               //       print(value);
//               //     });
//             },
//             icon: Icon(Icons.account_balance)),
//         const InkWell(
//             onTap: _launchURL, child: Text(style: TextStyle(color: Colors.blue), "https://github.com/vicortez")),
//         const Expanded(child: SizedBox.shrink()),
//         RichText(
//           text: TextSpan(
//             text: '',
//             style: DefaultTextStyle.of(context).style,
//             children: <TextSpan>[
//               TextSpan(
//                 text: 'Open experimental features page',
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () {
//                     // Perform your action here
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const TestPage()),
//                     );
//                   },
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         const Text("Version 0.22.0"),
//         const SizedBox(
//           height: 5,
//         )
//       ],
//     );
//   }
// }
//
// Future<http.Response> fetchAlbum() {
//   print('VOU BUSCAR');
//   return http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
// }
//
// _launchURL() async {
//   const url = 'https://github.com/vicortez';
//   final uri = Uri.parse(url);
//   if (await canLaunchUrl(uri)) {
//     await launchUrl(uri);
//   } else {
//     throw 'Could not launch $url';
//   }
// }
