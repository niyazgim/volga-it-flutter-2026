import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Receipts {
  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/receipts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<String> save(File file) async {
    final dir = await _dir();
    final name =
        '${DateTime.now().microsecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final dest = File('${dir.path}/$name');
    await file.copy(dest.path);
    return dest.path;
  }

  static Future<void> delete(String path) async {
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
