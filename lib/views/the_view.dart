import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:stickys/utils/sync.dart';
import 'package:stickys/views/list.dart';
import 'package:stickys/views/whiteboard.dart';

enum VIEW_MODE { LIST, CARDS }

const Map<VIEW_MODE, String> storageBucketNameMapping = {
  VIEW_MODE.LIST: 'list',
  VIEW_MODE.CARDS: 'cards'
};

abstract class TheView extends StatelessWidget {
  final Key key = UniqueKey();
  final TheViewController ctl;
  final LocalStorage bucket;
  final Syncer syncer = new Syncer();

  final VIEW_MODE viewMode;

  TheView(this.viewMode, TheViewController controller)
      : this.ctl = controller.runtimeType == TheListController
            ? Get.put<TheListController>(controller as TheListController)
            : Get.put<TheBoardController>(controller as TheBoardController),
        this.bucket = LocalStorage(storageBucketNameMapping[viewMode]!);

  List<String> newItemsFromCustomInput();

  hasValidSyncAccount() {
    final GetStorage g = GetStorage('Settings');
    return !(g.read('WebDavUserName').toString().length > 0 &&
        g.read('WebDavPassword').toString().length > 0);
  }

  upload() => syncer.uploadData(storageBucketNameMapping[viewMode],
      {'data': ctl.l.map((element) => element.serialize()).toList()});

  download() async {
    await syncer.getServerLastModifyTime();
    // print('last modify - server $lastModify');
    // print('last modify - client ${ctl.lastModifyTime}');

    Map? data = await (syncer.downloadData(storageBucketNameMapping[viewMode]));
    // print('got data');
    // print(data);
    if (data?['data'] != null) ctl.replaceBy(data!['data']);
  }
}

abstract class TheViewController extends DataController {
  final VIEW_MODE type;
  final RxList<ViewDataListItem> l;
  final LocalStorage storage;

  bool initiated = false;

  TheViewController(this.type)
      : this.storage = new LocalStorage(storageBucketNameMapping[type]!),
        this.l = new RxList<ViewDataListItem>();

  save() {
    this.storage.setItem(
        storageBucketNameMapping[type]!,
        this.l.map((item) {
          return item.serialize();
        }).toList());
    _updateModifyTime();
    // print("saved");
  }

  newItem(ViewDataListItem item, [bool insertToHead = true]) {
    if (insertToHead)
      this.l.insert(0, item);
    else
      this.l.add(item);
    update();
    save();
  }

  newItemFromString(String str);

  newItemsFromStringList(List<String> l);

  ViewDataListItem reverseSerialize(Map map);

  ViewDataListItem removeItemAt(int index) {
    var deleted = this.l.removeAt(index);
    update();
    save();
    return deleted;
  }

  ViewDataListItem findItem(Key dataKey) {
    return this.l.firstWhere((element) => element.dataKey == dataKey);
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
  Map<String, dynamic> serialize();
}

abstract class ViewDataListItem implements Serializable {
  final Key dataKey = UniqueKey();
  var content;
}
