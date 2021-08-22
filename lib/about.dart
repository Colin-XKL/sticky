import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

String encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

final Uri emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'Colin_XKL@outlook.com',
  query: encodeQueryParameters(
      <String, String>{'subject': 'Mind Box App Feedback'}),
);

class AboutPage extends StatelessWidget {
  final uri = emailLaunchUri.toString();

  void _newEmail() async =>
      await canLaunch(uri) ? await launch(uri) : throw 'Could not launch $uri';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Center(
          child: Stack(
        children: <Widget>[
          Align(
            alignment: FractionalOffset(0.5, 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  child: Icon(
                    Icons.control_point_duplicate_rounded,
                    size: 96,
                    color: Theme.of(context).indicatorColor,
                  ),
                  padding: EdgeInsets.all(48.0),
                ),
                Text(
                  "This is an app that can help you be a CV engineer. 🕶 Powered Copy&Paste experience.\n️",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  "If you have any questions or any good idea, just let me know.\nYou can tap the email address below to copy the address.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Align(
            alignment: FractionalOffset(0.5, 0.97),
            child: Text(
              "©2018-2021 X Studio All Rights Reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Align(
            alignment: FractionalOffset(0.5, 0.90),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: <Widget>[
                Text(
                  "Github Issue",
                ),
                TextButton(
                  child: Text(
                    "Email Feedback",
                  ),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: "Colin_XKL@outlook.com"));
                    _newEmail();
                  },
                ),
                Text(
                  "QQ Group",
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
