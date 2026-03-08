import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'settings_service.dart';

Future<String> saveAndOpenFile(String fileName, Uint8List bytes) async {
  String? savePath;

  // First check if user has set a custom save directory
  final customDir = SettingsService.releaseLetterDir;
  if (customDir != null && customDir.isNotEmpty) {
    // Ensure directory exists
    final dir = Directory(customDir);
    if (await dir.exists()) {
      savePath = customDir;
    }
  }

  // Fall back to Desktop on Windows
  if (savePath == null && Platform.isWindows) {
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      savePath = '$userProfile\\Desktop';
    }
  }

  if (savePath == null) {
    final dir = await getApplicationDocumentsDirectory();
    savePath = dir.path;
  }

  final rawPath = '$savePath/$fileName';
  // Normalize path separators for the current platform
  final filePath = Platform.isWindows ? rawPath.replaceAll('/', '\\') : rawPath;
  final file = File(filePath);
  await file.writeAsBytes(bytes);

  try {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [filePath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [filePath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [filePath]);
    }
  } catch (e) {}

  return filePath;
}
