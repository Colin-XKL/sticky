import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
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

  final VIEW_MODE viewMode;

  TheView(this.viewMode, TheViewController controller)
      : this.ctl = controller.runtimeType == TheListController
            ? Get.put<TheListController>(controller)
            : Get.put<TheBoardController>(controller),
        this.storage = LocalStorage(enumMapping[viewMode]);

  Object newItemFromCustomInput();
}

abstract class TheViewController extends GetxController {
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
    // print("saved");
  }

  newItem(ViewDataListItem item) {
    this.l.add(item);
    update();
    save();
  }

  newItemFromString(String str);

  ViewDataListItem removeItemAt(int index) {
    var deleted = this.l.removeAt(index);
    update();
    save();
    return deleted;
  }

  removeItem(Key dataKey) {
    this.l.removeWhere((element) => element.dataKey ==dataKey);
    update();
    save();
  }
}

abstract class Serializable {
  final Key key = UniqueKey();

  Map<String, dynamic> serialize();
}

abstract class ViewDataListItem extends Serializable {
  final Key dataKey=UniqueKey();
}
