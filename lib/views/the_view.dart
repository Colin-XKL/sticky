import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stickys/utils/sync.dart';
import 'package:stickys/views/list.dart';
import 'package:stickys/views/whiteboard.dart';

enum VIEW_MODE { LIST, CARDS }

const Map<VIEW_MODE, String> enumMapping = {
  VIEW_MODE.LIST: 'list',
  VIEW_MODE.CARDS: 'cards'
};

abstract class TheView extends StatelessWidget {
  final Key key = UniqueKey();
  final TheViewController ctl;
  final LocalStorage storage;
  final DataSync sync = new DataSync();

  final VIEW_MODE viewMode;

  TheView(this.viewMode, TheViewController controller)
      : this.ctl = controller.runtimeType == TheListController
            ? Get.put<TheListController>(controller)
            : Get.put<TheBoardController>(controller),
        this.storage = LocalStorage(enumMapping[viewMode]);

  Object newItemFromCustomInput();

  upload() => sync.uploadData(enumMapping[viewMode],
      {'data': ctl.l.map((element) => element.serialize()).toList()});

  download() async {
    // int lastModify =
    await sync.getServerLastModifyTime();
    // print('last modify - server $lastModify');
    // print('last modify - client ${ctl.lastModifyTime}');

    Map data = await sync.downloadData(enumMapping[viewMode]);
    // print('got data');
    // print(data);
    if (data['data'] != null) ctl.replaceBy(data['data']);
  }
}

abstract class TheViewController extends DataController {
  final VIEW_MODE type;
  final RxList<ViewDataListItem> l;
  final LocalStorage storage;

  bool initDone = false;

  TheViewController(this.type)
      : this.storage = new LocalStorage(enumMapping[type]),
        this.l = new RxList<ViewDataListItem>();

  save() {
    this.storage.setItem(
        enumMapping[type],
        this.l.map((item) {
          return item.serialize();
        }).toList());
    _updateModifyTime();
    // print("saved");
  }

  newItem(ViewDataListItem item) {
    this.l.add(item);
    update();
    save();
  }

  newItemFromString(String str);

  ViewDataListItem reverseSerialize(Map map);

  ViewDataListItem removeItemAt(int index) {
    var deleted = this.l.removeAt(index);
    update();
    save();
    return deleted;
  }

  removeItem(Key dataKey) {
    this.l.removeWhere((element) => element.dataKey == dataKey);
    update();
    save();
  }

  replaceBy(List newList) {
    this.l.clear();
    // print('new list');
    // print(newList);
    this.l.addAll(newList.map((e) => reverseSerialize(e)));
    // print(this.l);
    update();
    save();
  }
}

abstract class DataController extends GetxController {
  int lastModifyTime = DateTime.now().millisecondsSinceEpoch;

  save();

  _updateModifyTime() {
    this.lastModifyTime = DateTime.now().millisecondsSinceEpoch;
  }
}

abstract class Serializable {
  final Key key = UniqueKey();

  Map<String, dynamic> serialize();
}

abstract class ViewDataListItem extends Serializable {
  final Key dataKey = UniqueKey();
}
