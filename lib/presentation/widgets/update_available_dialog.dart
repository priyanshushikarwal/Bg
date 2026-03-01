import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/updater_service.dart';

/// A dialog that walks through four states:
///   1. Initial – shows release info with "Later" / "Update Now"
///   2. Downloading – streaming progress bar
///   3. Installing – indeterminate spinner, then app exits
///   4. Error – retry / cancel
class UpdateAvailableDialog extends StatefulWidget {
  final String currentVersion;
  final String newVersion;
  final String releaseNotes;
  final String downloadUrl;

  const UpdateAvailableDialog({
    super.key,
    required this.currentVersion,
    required this.newVersion,
    required this.releaseNotes,
    required this.downloadUrl,
  });

  @override
  State<UpdateAvailableDialog> createState() => _UpdateAvailableDialogState();
}

enum _UpdateState { initial, downloading, installing, error }

class _UpdateAvailableDialogState extends State<UpdateAvailableDialog> {
  _UpdateState _state = _UpdateState.initial;
  double _progress = 0.0;
  String _errorMessage = '';
  final UpdaterService _updaterService = UpdaterService();
  String? _savedZipPath;

  // ------------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------------

  Future<void> _startDownload() async {
    setState(() {
      _state = _UpdateState.downloading;
      _progress = 0.0;
    });

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _savedZipPath = '${Directory.systemTemp.path}\\app_update_$timestamp.zip';

    try {
      await _updaterService.downloadUpdate(
        widget.downloadUrl,
        _savedZipPath!,
        (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );

      if (!mounted) return;

      // Move to installing
      setState(() => _state = _UpdateState.installing);

      await _updaterService.installUpdateAndRestart(_savedZipPath!);
      // The app will exit inside installUpdateAndRestart — we should never
      // reach this line.
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UpdateState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // ------------------------------------------------------------------
  // UI
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext dialogContext) {
    switch (_state) {
      case _UpdateState.initial:
        return _buildInitial(dialogContext);
      case _UpdateState.downloading:
        return _buildDownloading(dialogContext);
      case _UpdateState.installing:
        return _buildInstalling();
      case _UpdateState.error:
        return _buildError(dialogContext);
    }
  }

  // ---- STATE 1: Initial ---------------------------------------------------

  Widget _buildInitial(BuildContext dialogContext) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.system_update_alt_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Update Available',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _versionRow('Current version', widget.currentVersion),
        const SizedBox(height: 6),
        _versionRow('New version', widget.newVersion),
        const SizedBox(height: 16),
        const Text('Release Notes',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.releaseNotes,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Later'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _startDownload,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Update Now'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _versionRow(String label, String version) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'v$version',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ---- STATE 2: Downloading ------------------------------------------------

  Widget _buildDownloading(BuildContext dialogContext) {
    final percentage = (_progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.downloading_rounded,
            size: 48, color: AppColors.primary),
        const SizedBox(height: 16),
        const Text('Downloading Update...',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Downloading... $percentage%',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ---- STATE 3: Installing -------------------------------------------------

  Widget _buildInstalling() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        SizedBox(height: 20),
        Text('Installing update...',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(
          'The app will restart automatically.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  // ---- STATE 4: Error ------------------------------------------------------

  Widget _buildError(BuildContext dialogContext) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded,
            size: 48, color: Colors.redAccent),
        const SizedBox(height: 16),
        const Text('Update Failed',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _errorMessage,
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => setState(() => _state = _UpdateState.initial),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ],
    );
  }
}
