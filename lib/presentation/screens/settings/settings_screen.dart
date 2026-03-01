import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/update_available_dialog.dart';

/// Settings screen that currently provides an "Updates" section.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _checkingForUpdates = false;

  // ------------------------------------------------------------------
  // Version comparison helper
  // ------------------------------------------------------------------

  /// Returns `true` when [remote] is newer than [local].
  bool _isNewer(String remote, String local) {
    final rParts = remote.split('.').map(int.tryParse).toList();
    final lParts = local.split('.').map(int.tryParse).toList();
    final len = rParts.length > lParts.length ? rParts.length : lParts.length;
    for (int i = 0; i < len; i++) {
      final r = i < rParts.length ? (rParts[i] ?? 0) : 0;
      final l = i < lParts.length ? (lParts[i] ?? 0) : 0;
      if (r > l) return true;
      if (r < l) return false;
    }
    return false;
  }

  // ------------------------------------------------------------------
  // Check for updates
  // ------------------------------------------------------------------

  Future<void> _checkForUpdates() async {
    if (_checkingForUpdates) return;
    setState(() => _checkingForUpdates = true);

    try {
      const versionUrl =
          'https://raw.githubusercontent.com/priyanshushikarwal/Bg-updates/main/version.json';

      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final remoteVersion = data['version'] as String;
      final downloadUrl = data['url'] as String;
      final notes = (data['notes'] as String?) ?? 'No release notes.';
      final currentVersion = AppStrings.appVersion;

      if (!mounted) return;

      if (_isNewer(remoteVersion, currentVersion)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => UpdateAvailableDialog(
            currentVersion: currentVersion,
            newVersion: remoteVersion,
            releaseNotes: notes,
            downloadUrl: downloadUrl,
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.green.shade600, size: 28),
                const SizedBox(width: 10),
                const Text('Up to Date'),
              ],
            ),
            content: Text(
              'You\'re running the latest version (v$currentVersion).',
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.red.shade600, size: 28),
              const SizedBox(width: 10),
              const Text('Error'),
            ],
          ),
          content: Text(
            'Could not check for updates.\n\n$e',
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingForUpdates = false);
    }
  }

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Updates
          _SectionCard(
            title: 'Updates',
            icon: Icons.system_update_alt_rounded,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Version',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'v${AppStrings.appVersion}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _checkingForUpdates ? null : _checkForUpdates,
                    icon: _checkingForUpdates
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      _checkingForUpdates
                          ? 'Checking...'
                          : 'Check for Updates',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// Reusable section card
// ==========================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
