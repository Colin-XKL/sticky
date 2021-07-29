import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
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
                    Icons.paste_rounded,
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
            alignment: FractionalOffset(0, 0.93),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "QUESTIONS",
                  ),
                ),
                TextButton(
                  child: Text(
                    "Colin_XKL@outlook.com",
                  ),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: "Colin_XKL@outlook.com"));
                  },
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "IDEAS",
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
