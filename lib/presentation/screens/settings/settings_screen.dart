import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/settings_service.dart';
import '../../providers/bg_providers.dart';
import '../../widgets/update_available_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _checkingForUpdates = false;
  String? _releaseLetterDir;
  final _newFirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _releaseLetterDir = SettingsService.releaseLetterDir;
  }

  @override
  void dispose() {
    _newFirmController.dispose();
    super.dispose();
  }

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
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 28,
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade600,
                size: 28,
              ),
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

  Future<void> _pickReleaseLetterDir() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select folder for Release Letters',
    );
    if (result != null) {
      await SettingsService.setReleaseLetterDir(result);
      setState(() => _releaseLetterDir = result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Release letters will be saved to: $result'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _resetReleaseLetterDir() async {
    await SettingsService.setReleaseLetterDir(null);
    setState(() => _releaseLetterDir = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Release letter save location reset to Desktop'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  String _getDefaultPath() {
    if (!kIsWeb && Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) return '$userProfile\\Desktop';
    }
    return 'Documents';
  }

  Future<void> _addFirm() async {
    final name = _newFirmController.text.trim();
    if (name.isEmpty) return;

    await ref.read(firmNamesProvider.notifier).addFirm(name);
    _newFirmController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firm "$name" added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _removeFirm(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 26),
            const SizedBox(width: 10),
            const Text('Delete Firm'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$name"?\n\nExisting BGs with this firm will keep their firm name, but it will no longer appear in the dropdown.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(firmNamesProvider.notifier).removeFirm(name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firm "$name" deleted'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  Future<void> _editFirmDetails(String firmName) async {
    final details = SettingsService.getFirmDetails(firmName);
    final addressController = TextEditingController(text: details.address);
    final emailController = TextEditingController(text: details.email);
    final mobileController = TextEditingController(text: details.mobile);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Edit Firm Details',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firmName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'These details will appear on the letterhead of release letters generated for this firm.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              _buildDetailField(addressController, 'Address', Icons.location_on_rounded),
              const SizedBox(height: 12),
              _buildDetailField(emailController, 'Email ID', Icons.email_rounded),
              const SizedBox(height: 12),
              _buildDetailField(mobileController, 'Mobile Number', Icons.phone_rounded),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      await ref.read(firmNamesProvider.notifier).saveFirmDetails(
        FirmDetails(
          name: firmName,
          address: addressController.text.trim(),
          email: emailController.text.trim(),
          mobile: mobileController.text.trim(),
        ),
      );
      setState(() {}); // refresh UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Details for "$firmName" saved & synced to cloud'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    addressController.dispose();
    emailController.dispose();
    mobileController.dispose();
  }

  Widget _buildDetailField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
      ),
      style: const TextStyle(fontSize: 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firms = ref.watch(firmNamesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Firm Management Section
          _SectionCard(
            title: 'Manage Firms',
            icon: Icons.business_rounded,
            children: [
              const Text(
                'Your Firms',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Add or remove firms that appear in the sidebar and BG forms.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              // Add new firm row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newFirmController,
                      decoration: InputDecoration(
                        hintText: 'Enter new firm name...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        prefixIcon: const Icon(Icons.add_business_rounded, size: 20, color: AppColors.primary),
                      ),
                      style: const TextStyle(fontSize: 13),
                      onSubmitted: (_) => _addFirm(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _addFirm,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Firm'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Firms list
              ...firms.asMap().entries.map((entry) {
                final index = entry.key;
                final firm = entry.value;
                final details = SettingsService.getFirmDetails(firm);
                final hasDetails = details.address.isNotEmpty || details.email.isNotEmpty || details.mobile.isNotEmpty;
                return Container(
                  margin: EdgeInsets.only(bottom: index < firms.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firm,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (hasDetails) ...[
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (details.address.isNotEmpty) details.address,
                                  if (details.email.isNotEmpty) details.email,
                                  if (details.mobile.isNotEmpty) 'Mob: ${details.mobile}',
                                ].join(' • '),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ] else ...[
                              const SizedBox(height: 2),
                              Text(
                                'No details set – click Edit to add address, email & mobile',
                                style: TextStyle(fontSize: 11, color: Colors.orange.shade400, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _editFirmDetails(firm),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _removeFirm(firm),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                        tooltip: 'Delete firm',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),

          if (!kIsWeb) ...[
            const SizedBox(height: 24),

            // File Storage Section
            _SectionCard(
              title: 'File Storage',
              icon: Icons.folder_rounded,
              children: [
                const Text(
                  'Release Letter Save Location',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose where release letters and exported reports are saved.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _releaseLetterDir != null
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _releaseLetterDir != null
                              ? Icons.folder_rounded
                              : Icons.desktop_windows_rounded,
                          color: _releaseLetterDir != null
                              ? AppColors.success
                              : AppColors.info,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _releaseLetterDir != null
                                  ? 'Custom Location'
                                  : 'Default Location',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _releaseLetterDir ?? _getDefaultPath(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_releaseLetterDir != null)
                        OutlinedButton.icon(
                          onPressed: _resetReleaseLetterDir,
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: BorderSide(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _pickReleaseLetterDir,
                        icon: const Icon(Icons.folder_open_rounded, size: 16),
                        label: const Text('Browse'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Updates Section
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                        _checkingForUpdates ? 'Checking...' : 'Check for Updates',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

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
