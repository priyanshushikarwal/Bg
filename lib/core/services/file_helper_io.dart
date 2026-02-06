import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> saveAndOpenFile(String fileName, Uint8List bytes) async {
  String? savePath;

  if (Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      savePath = '$userProfile\\Desktop';
    }
  }

  if (savePath == null) {
    final dir = await getApplicationDocumentsDirectory();
    savePath = dir.path;
  }

  final filePath = '$savePath/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes);

  // Open the file
  try {
    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', filePath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [filePath]);
    }
  } catch (e) {
    // Ignore open errors
  }

  return filePath;
}
