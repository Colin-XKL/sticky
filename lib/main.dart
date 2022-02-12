import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:stickys/pages/setting.dart';
import 'package:stickys/utils/platform.dart';
import 'package:stickys/views/the_item.dart';
import 'package:stickys/views/the_view.dart';
import 'views/list.dart';
import 'views/whiteboard.dart';
// import 'views/block.dart';
import 'pages/about.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  GetStorage g = GetStorage('Settings');
  await GetStorage.init();
  g.write("WebDavEntrypoint", "https://dav.jianguoyun.com/dav/");

  final LocalStorage listStorage = new LocalStorage('list');
  final LocalStorage boardStorage = new LocalStorage('cards');

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  await listStorage.ready;
  await boardStorage.ready;

  Sentry.configureScope((scope) {
    Map appInfo = {
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
    };
    scope.setTag('Platform', PlatformInfo.getPlatformString() ?? "Unknown");
    scope.setContexts('AppInfo', appInfo);
  });
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://246fb2d534314bf3935d50f4ef0afd0b@o850059.ingest.sentry.io/5884653';
    },
    appRunner: () => runApp(MyApp()),
  );
  Get.put<AppInfoController>(AppInfoController());
  final AppInfoController ctl = Get.find<AppInfoController>();
  ctl.updateData(packageInfo.version, packageInfo.buildNumber);
  Get.put(InputOptionsController());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Ender Box",
      theme: ThemeData(
        fontFamily: "Microsoft Yahei UI",
        appBarTheme: ThemeData.light().appBarTheme.copyWith(
            backgroundColor: Colors.white, foregroundColor: Colors.black87),
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: Colors.teal,
              secondary: Colors.teal,
            ),
      ),
      darkTheme: ThemeData(
        fontFamily: "Microsoft Yahei UI",
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Colors.teal,
              secondary: Colors.teal,
            ),
      ),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  final ViewManager viewManager = new ViewManager();

  @override
  State<StatefulWidget> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final msgEmpty = new SnackBar(
    content: Text("剪贴板为空！"),
    duration: Duration(milliseconds: 500),
  );
  final msgPasted = new SnackBar(
    content: Text("已粘贴"),
    duration: Duration(milliseconds: 300),
  );
  late TheView view;

  @override
  void initState() {
    super.initState();
    this.view = widget.viewManager.getView();
  }

  void newItemTriggeredByKey() {
    VIEW_MODE currentView = widget.viewManager.getCurrentViewType();
    if (currentView == VIEW_MODE.LIST) {
      //list
      final TheListController c = Get.find();
      c.l.add(ListItem("空 ", ""));
    } else if (currentView == VIEW_MODE.CARDS) {
      //whiteboard
      final TheBoardController wbc = Get.find();
      wbc.l.add(
        new CardData(ITEM_TYPE.TEXT, TextCardContent("无内容")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AreaWithKeyShortcut(
        onPasteDetected: () async {
          if (await pasteFromPastebin()) //has content
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(msgPasted);
        },
        onNewEmptyItemDetected: newItemTriggeredByKey,
        child: Scaffold(
            appBar: new AppBar(
              // foregroundColor: Colors.white,
              title: Text("Ender Box"),
              actions: [
                IconButton(
                  onPressed: () => view.download(),
                  icon: Icon(Icons.download),
                ),
                IconButton(
                    onPressed: () => view.upload(), icon: Icon(Icons.save)),
              ],
            ),
            drawer: Drawer(
                child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountEmail: null,
                    accountName: null,
                  ),
                  ListTile(
                    title: Text("列表模式"),
                    leading: Icon(Icons.format_list_bulleted_rounded),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {},
                    ),
                    onTap: () {
                      setState(() {
                        widget.viewManager.setCurrentViewIndex(0);
                        this.view = widget.viewManager.getView();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text("白板模式"),
                    leading: Icon(Icons.dashboard_sharp),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {},
                    ),
                    onTap: () {
                      setState(() {
                        widget.viewManager.setCurrentViewIndex(1);
                        this.view = widget.viewManager.getView();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  // ListTile(
                  //   title: Text("Block"),
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => BlockPage()));
                  //   },
                  // ),
                  Divider(),
                  ListTile(
                    title: Text("设置"),
                    // leading: Icon(Icons.settings,size: 24,),
                    dense: true,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()));
                    },
                  ),
                  ListTile(
                    title: Text("关于 EnderBox"),
                    dense: true,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                  ),
                  ListTile(
                    title: Text("作者博客"),
                    dense: true,
                    onTap: () {
                      launch("https://blog.colinx.one/");
                    },
                  ),
                  // ListTile(
                  //   title: Text("给项目送上 star!"),
                  //   dense: true,
                  //   onTap: () {
                  //     launch("https://github.com/Colin-XKL/sticky");
                  //   },
                  // ),
                  ListTile(
                    title: Text('退出'),
                    dense: true,
                    onTap: () => {exit(0)},
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 32, 0, 0),
                    child: Text(
                      "EnderBox, your last productivity app",
                      softWrap: true,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  )
                ],
              ),
            )),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                List<String> ret = view.newItemsFromCustomInput();
                if (ret.length > 0)
                  view.ctl.newItemsFromStringList(ret);
                else if (await pasteFromPastebin()) //hasContent
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(msgPasted);
              },
            ),
            body: view));
  }

  Future<bool> pasteFromPastebin() async {
    var controller = view.ctl;
    return Clipboard.getData(Clipboard.kTextPlain).then((value) {
      bool notEmpty =
          (value != null && value.text != null && value.text!.isNotEmpty);
      controller.newItemFromString(value?.text ?? "");

      Clipboard.setData(ClipboardData(text: ""));
      return notEmpty;
    });
  }
}

class ViewManager {
  int currentViewIndex = 0;
  List<TheView> views = [new TheList(), new TheBoard()];

  TheView getView() {
    if (currentViewIndex >= 0 && currentViewIndex < views.length)
      return views[currentViewIndex];
    else
      this.views.add(new TheList());
    return this.views[0];
  }

  VIEW_MODE getCurrentViewType() {
    return getView().viewMode;
  }

  bool setCurrentViewIndex(int i) {
    if (i >= 0 && i < views.length) {
      this.currentViewIndex = i;
      return true;
    }
    return false;
  }
}

// KEY SHORTCUT RESPONSE
class AreaWithKeyShortcut extends StatelessWidget {
  const AreaWithKeyShortcut({
    Key? key,
    required this.child,
    required this.onPasteDetected,
    required this.onNewEmptyItemDetected,
  }) : super(key: key);
  final Widget child;
  final VoidCallback onPasteDetected;
  final VoidCallback onNewEmptyItemDetected;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: true,
      shortcuts: {
        newEmptyItemKeySet: NewEmptyItemIntent(),
        pasteKeySet: PasteIntent(),
      },
      actions: {
        PasteIntent: CallbackAction(onInvoke: (e) => onPasteDetected.call()),
        NewEmptyItemIntent:
            CallbackAction(onInvoke: (e) => onNewEmptyItemDetected.call()),
      },
      child: child,
    );
  }
}

final newEmptyItemKeySet =
    LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control);
final pasteKeySet = LogicalKeySet(LogicalKeyboardKey.paste);

class PasteIntent extends Intent {}

class NewEmptyItemIntent extends Intent {}
