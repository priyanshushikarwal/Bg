import 'dart:io';

import 'package:http/http.dart' as http;

/// Service that handles downloading updates, generating a PowerShell updater
/// script, and restarting the application after the update is applied.
class UpdaterService {
  /// Downloads a file from [url] to [savePath] using streaming so that large
  /// files (100 MB+) don't need to be held in memory. [onProgress] is called
  /// with a value between 0.0 and 1.0 as bytes arrive.
  Future<void> downloadUpdate(
    String url,
    String savePath,
    void Function(double progress) onProgress,
  ) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download update: HTTP ${response.statusCode}',
        );
      }

      final totalBytes = response.contentLength ?? -1;
      int bytesReceived = 0;

      final file = File(savePath);
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        bytesReceived += chunk.length;
        if (totalBytes > 0) {
          onProgress(bytesReceived / totalBytes);
        }
      }

      await sink.flush();
      await sink.close();
    } finally {
      client.close();
    }
  }

  /// Extracts the downloaded ZIP, replaces the running app directory, and
  /// restarts the application. The method writes a hidden PowerShell script
  /// that performs the actual file replacement once this process exits.
  Future<void> installUpdateAndRestart(String downloadedZipPath) async {
    final currentExePath = Platform.resolvedExecutable;
    final appDir = File(currentExePath).parent.path;

    final script = _generateUpdaterScript(currentExePath, appDir, downloadedZipPath);
    final scriptPath =
        '${Directory.systemTemp.path}\\app_updater_${DateTime.now().millisecondsSinceEpoch}.ps1';
    await File(scriptPath).writeAsString(script);

    final bool needsAdmin = appDir.toLowerCase().contains('program files');

    if (needsAdmin) {
      // Launch with UAC elevation via cmd to ensure process independence
      await Process.start(
        'cmd',
        [
          '/c',
          'start',
          '/b',
          'powershell',
          '-Command',
          'Start-Process',
          'powershell',
          '-ArgumentList',
          "'-ExecutionPolicy Bypass -WindowStyle Hidden -File \"$scriptPath\"'",
          '-Verb',
          'RunAs',
        ],
        mode: ProcessStartMode.detached,
      );
    } else {
      // Launch via cmd /c start to create a fully independent process chain
      // so exit(0) cannot kill the updater script
      await Process.start(
        'cmd',
        [
          '/c',
          'start',
          '/b',
          'powershell',
          '-ExecutionPolicy',
          'Bypass',
          '-WindowStyle',
          'Hidden',
          '-File',
          scriptPath,
        ],
        mode: ProcessStartMode.detached,
      );
    }

    // Give the detached process time to fully initialize before exiting
    await Future.delayed(const Duration(seconds: 3));

    // Exit the current app so the script can replace files
    exit(0);
  }

  /// Builds the PowerShell script content that will:
  /// 1. Wait for the running app to exit
  /// 2. Extract the ZIP to a temp folder
  /// 3. Backup the current app directory
  /// 4. Copy new files over the app directory
  /// 5. Clean up and restart the app
  String _generateUpdaterScript(
    String currentExePath,
    String appDir,
    String zipPath,
  ) {
    final escapedExe = _escapePowerShellPath(currentExePath);
    final escapedAppDir = _escapePowerShellPath(appDir);
    final escapedZip = _escapePowerShellPath(zipPath);

    // Derive process name (without .exe extension)
    final exeName = currentExePath.split('\\').last;
    final processName =
        exeName.endsWith('.exe') ? exeName.substring(0, exeName.length - 4) : exeName;
    final escapedProcessName = _escapePowerShellPath(processName);

    // Use a single Dart string with \$ to prevent Dart interpolation where
    // we want literal PowerShell $ signs.
    return '''
\$logFile = "\$env:TEMP\\app_updater.log"

function Log(\$message) {
    \$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "\$timestamp - \$message" | Out-File -FilePath \$logFile -Append -Encoding UTF8
}

try {
    Log "=== Update process started ==="

    # Give the Dart app a moment to fully exit
    Start-Sleep -Seconds 3

    \$processName = '$escapedProcessName'
    \$currentExe = '$escapedExe'
    \$appDir = '$escapedAppDir'
    \$zipPath = '$escapedZip'

    # 1. Wait for the application to exit (up to 30 seconds)
    Log "Waiting for \$processName to exit..."
    \$waited = 0
    while (\$waited -lt 30) {
        \$proc = Get-Process -Name \$processName -ErrorAction SilentlyContinue
        if (-not \$proc) {
            Log "Process exited."
            break
        }
        Start-Sleep -Seconds 1
        \$waited++
    }

    # Force-kill if still running
    \$proc = Get-Process -Name \$processName -ErrorAction SilentlyContinue
    if (\$proc) {
        Log "Force-killing \$processName..."
        Stop-Process -Name \$processName -Force
        Start-Sleep -Seconds 2
    }

    # 2. Extract ZIP to temp folder
    \$extractDir = "\$env:TEMP\\app_update_extract_\$((Get-Date).Ticks)"
    Log "Extracting ZIP to \$extractDir..."
    Expand-Archive -Path \$zipPath -DestinationPath \$extractDir -Force

    # 3. Auto-detect if ZIP has a single subfolder
    \$items = Get-ChildItem -Path \$extractDir
    if (\$items.Count -eq 1 -and \$items[0].PSIsContainer) {
        \$sourceDir = \$items[0].FullName
        Log "Detected single subfolder: \$sourceDir"
    } else {
        \$sourceDir = \$extractDir
        Log "Using extract root as source."
    }

    # 4. Backup current app directory
    \$backupDir = "\$appDir" + "_backup"
    if (Test-Path \$backupDir) {
        Log "Removing old backup..."
        Remove-Item -Path \$backupDir -Recurse -Force
    }
    Log "Backing up \$appDir to \$backupDir..."
    Copy-Item -Path \$appDir -Destination \$backupDir -Recurse -Force

    # 5. Copy new files over app directory
    Log "Copying new files to \$appDir..."
    Copy-Item -Path "\$sourceDir\\*" -Destination \$appDir -Recurse -Force

    # 6. Cleanup
    Log "Cleaning up ZIP and temp files..."
    Remove-Item -Path \$zipPath -Force -ErrorAction SilentlyContinue
    Remove-Item -Path \$extractDir -Recurse -Force -ErrorAction SilentlyContinue

    # 7. Restart app
    Log "Restarting application: \$currentExe"
    Start-Process -FilePath \$currentExe

    Log "=== Update completed successfully ==="
} catch {
    Log "ERROR: \$_"
    Log \$_.ScriptStackTrace
}

# Self-delete
try {
    Remove-Item \$MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue
} catch {}
''';
  }

  /// Escapes a path for safe embedding in single-quoted PowerShell strings.
  String _escapePowerShellPath(String path) {
    return path.replaceAll("'", "''");
  }
}
