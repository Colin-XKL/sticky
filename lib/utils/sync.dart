import 'dart:convert';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'package:webdav_client/webdav_client.dart';

class DataSync {
  static const rootURI = "/MindBox";
  static const lastModifyDataURI = '/MindBox/lastModifyTime';
  final Client client;

  DataSync()
      : this.client = (() {
          final GetStorage g = GetStorage('Settings');

          return newClient(g.read('WebDavEntrypoint') ?? "/",
              user: g.read('WebDavUserName') ?? "",
              password: g.read('WebDavPassword') ?? "");
        })();

  init() async {
    client.mkdir(rootURI);
  }

  setServerLastModifyTime([int? lastModifyTime]) async {
    await client.write(
        lastModifyDataURI,
        lastModifyTime as Uint8List? ??
            utf8.encode((DateTime.now().millisecondsSinceEpoch).toString()) as Uint8List);
  }

  Future<int> getServerLastModifyTime() async {
    var byteData = await client.read(lastModifyDataURI);
    String charData = utf8.decode(byteData);
    return num.parse(charData).toInt();
  }

  uploadData(String? bucket, Map data, [int? lastModifyTime]) async {
    // print('uploading');
    await getServerLastModifyTime();
    await init();
    await client.write("$rootURI/$bucket.json", utf8.encode(json.encode(data)) as Uint8List);
    await setServerLastModifyTime(lastModifyTime);
    // print('write done');
  }

  Future<Map?> downloadData(String? bucket) async {
    var byteData = await client.read("$rootURI/$bucket.json");
    String charData = utf8.decode(byteData);
    Map<String, dynamic>? data = json.decode(charData);
    // print(data);
    return data;
  }
}
