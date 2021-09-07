import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  final GetStorage g = GetStorage('Settings');

  final TextEditingController _accountCtl = TextEditingController(text: (() {
    GetStorage g = GetStorage('Settings');
    return g.read('WebDavUserName') ?? "";
  })());
  final TextEditingController _tokenCtl = TextEditingController(text: (() {
    GetStorage g = GetStorage('Settings');
    return g.read('WebDavPassword') ?? "";
  })());

  void _saveAccount() {
    g.write('WebDavUserName', _accountCtl.text);
  }

  void _saveToken() {
    g.write('WebDavPassword', _tokenCtl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SingleChildScrollView(
            child: Wrap(children: [
          // Padding(
          // padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
          // child:
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Wrap(
                children: [
                  Card(
                    margin: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 2),
                          child: Text(
                              "WebDAV settings ( Default Provider: NutStore )",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        Divider(),
                        TextField(
                          controller: _accountCtl,
                          onEditingComplete: _saveAccount,
                          decoration: InputDecoration(
                              hintText: "用户名或邮箱",
                              // border: InputBorder.none,
                              // focusedBorder: UnderlineInputBorder(),
                              prefixIcon: Icon(
                                Icons.account_box_rounded,
                                size: 24,
                              ),
                              enabledBorder: InputBorder.none),
                        ),
                        TextField(
                          controller: _tokenCtl,
                          onEditingComplete: _saveToken,
                          decoration: InputDecoration(
                              hintText: "WebDav密钥",
                              // border: InputBorder.none,
                              // focusedBorder: UnderlineInputBorder(),
                              prefixIcon:
                                  Icon(Icons.security_rounded, size: 22),
                              enabledBorder: InputBorder.none),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 2),
                          child: Text("The Settings",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        Divider(),
                        SwitchListTile.adaptive(
                            title: Text("Dark Theme"),
                            value: Get.isDarkMode,
                            onChanged: (darkMode) {
                              // print("Clicked");
                              Get.changeTheme(Get.isDarkMode
                                  ? ThemeData.light()
                                  : ThemeData.dark());
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Switching theme...")));
                            })
                      ],
                    ),
                  )
                ],
              )),
          // ),
        ])));
  }
}
