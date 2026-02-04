import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/bg_model.dart';
import '../../providers/bg_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/premium_buttons.dart';
import '../../widgets/premium_inputs.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String _searchQuery = '';
  DocumentType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final allBgsAsync = ref.watch(allBgsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.info.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.folder_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documents',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'All BG documents in one place',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GradientButton(
                text: 'Upload Document',
                icon: Icons.upload_file_rounded,
                gradient: AppColors.blueGradient,
                onPressed: () => _showUploadDocumentDialog(context),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // Search and Filters
          Row(
            children: [
              Expanded(
                child: PremiumSearchBar(
                  hint: 'Search documents...',
                  onChanged: (query) => setState(() => _searchQuery = query),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              _buildTypeFilter(),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // Documents Grid
          Expanded(
            child: allBgsAsync.when(
              data: (bgs) => _buildDocumentsGrid(context, bgs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorStateWidget(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Row(
      children: [
        PremiumFilterChip(
          label: 'All',
          isSelected: _selectedType == null,
          onTap: () => setState(() => _selectedType = null),
        ),
        const SizedBox(width: AppDimensions.spaceXs),
        PremiumFilterChip(
          label: 'Original BG',
          isSelected: _selectedType == DocumentType.originalBgCopy,
          onTap: () =>
              setState(() => _selectedType = DocumentType.originalBgCopy),
        ),
        const SizedBox(width: AppDimensions.spaceXs),
        PremiumFilterChip(
          label: 'Extended BG',
          isSelected: _selectedType == DocumentType.extendedBgCopy,
          onTap: () =>
              setState(() => _selectedType = DocumentType.extendedBgCopy),
        ),
        const SizedBox(width: AppDimensions.spaceXs),
        PremiumFilterChip(
          label: 'Release Letter',
          isSelected: _selectedType == DocumentType.releaseLetter,
          onTap: () =>
              setState(() => _selectedType = DocumentType.releaseLetter),
        ),
      ],
    );
  }

  Widget _buildDocumentsGrid(BuildContext context, List<BgModel> bgs) {
    final dateFormat = DateFormat('dd MMM yyyy');

    // Collect all documents with BG info
    final List<Map<String, dynamic>> allDocs = [];
    for (final bg in bgs) {
      for (final doc in bg.documents) {
        if (_selectedType == null || doc.type == _selectedType) {
          if (_searchQuery.isEmpty ||
              doc.fileName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              bg.bgNumber.toLowerCase().contains(_searchQuery.toLowerCase())) {
            allDocs.add({'bg': bg, 'doc': doc});
          }
        }
      }
    }

    if (allDocs.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.folder_open_rounded,
        title: 'No Documents Found',
        description: 'Upload documents to BGs to see them here',
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.1,
        crossAxisSpacing: AppDimensions.spaceMd,
        mainAxisSpacing: AppDimensions.spaceMd,
      ),
      itemCount: allDocs.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final data = allDocs[index];
        final BgModel bg = data['bg'];
        final DocumentModel doc = data['doc'];

        return PremiumCard(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getDocTypeColor(
                            doc.type,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Icon(
                          _getDocTypeIcon(doc.type),
                          color: _getDocTypeColor(doc.type),
                          size: 24,
                        ),
                      ),
                      PremiumIconButton(
                        icon: Icons.more_vert_rounded,
                        onPressed: () {},
                        size: 32,
                        iconSize: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Text(
                    doc.typeDisplayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BG: ${bg.bgNumber}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'v${doc.version}',
                            style: TextStyle(
                              color: AppColors.primaryPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dateFormat.format(doc.uploadDate),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          PremiumIconButton(
                            icon: Icons.visibility_rounded,
                            tooltip: 'Preview',
                            onPressed: () {},
                            size: 32,
                            iconSize: 16,
                          ),
                          PremiumIconButton(
                            icon: Icons.download_rounded,
                            tooltip: 'Download',
                            onPressed: () {},
                            size: 32,
                            iconSize: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
            .animate(delay: Duration(milliseconds: index * 30))
            .fadeIn()
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 200),
            );
      },
    );
  }

  Color _getDocTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.originalBgCopy:
        return AppColors.info;
      case DocumentType.extendedBgCopy:
        return AppColors.warning;
      case DocumentType.releaseLetter:
        return AppColors.success;
      case DocumentType.other:
        return AppColors.textSecondary;
    }
  }

  IconData _getDocTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.originalBgCopy:
        return Icons.description_rounded;
      case DocumentType.extendedBgCopy:
        return Icons.update_rounded;
      case DocumentType.releaseLetter:
        return Icons.verified_rounded;
      case DocumentType.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  void _showUploadDocumentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _UploadDocumentDialog(ref: ref),
    );
  }
}

class _UploadDocumentDialog extends StatefulWidget {
  final WidgetRef ref;

  const _UploadDocumentDialog({required this.ref});

  @override
  State<_UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<_UploadDocumentDialog> {
  String? _selectedBgId;
  DocumentType? _selectedType;
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final allBgsAsync = widget.ref.watch(allBgsProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Document',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'Attach document to a BG',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Select BG dropdown
            allBgsAsync.when(
              data: (bgs) {
                return DropdownButtonFormField<String>(
                  value: _selectedBgId,
                  decoration: InputDecoration(
                    labelText: 'Select BG *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: bgs
                      .map(
                        (bg) => DropdownMenuItem(
                          value: bg.id,
                          child: Text('${bg.bgNumber} - ${bg.bankName}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBgId = value),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading BGs'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DocumentType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Document Type *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: DocumentType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_getTypeName(t)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFilePath != null
                        ? AppColors.success
                        : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: _selectedFilePath != null
                      ? AppColors.success.withValues(alpha: 0.05)
                      : null,
                ),
                child: Center(
                  child: _selectedFilePath != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFileName ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_rounded,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Click to select file',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSubmit() && !_isLoading ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }

  String _getTypeName(DocumentType t) {
    switch (t) {
      case DocumentType.originalBgCopy:
        return 'Original BG Copy';
      case DocumentType.extendedBgCopy:
        return 'Extended BG Copy';
      case DocumentType.releaseLetter:
        return 'Release Letter';
      case DocumentType.other:
        return 'Other';
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  bool _canSubmit() {
    return _selectedBgId != null &&
        _selectedType != null &&
        _selectedFilePath != null;
  }

  void _submit() async {
    setState(() => _isLoading = true);
    try {
      final allBgs = widget.ref.read(allBgsProvider).value ?? [];
      final selectedBg = allBgs.firstWhere((bg) => bg.id == _selectedBgId);

      final existingDocs = selectedBg.documents
          .where((d) => d.type == _selectedType)
          .toList();
      final doc = DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType!,
        fileName: _selectedFileName ?? 'document',
        filePath: _selectedFilePath!,
        uploadDate: DateTime.now(),
        version: existingDocs.length + 1,
      );

      final updatedBg = selectedBg.copyWith(
        documents: [...selectedBg.documents, doc],
        updatedAt: DateTime.now(),
      );

      final repo = widget.ref.read(bgRepositoryProvider);
      await repo.updateBg(updatedBg);

      widget.ref.invalidate(allBgsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document uploaded to ${selectedBg.bgNumber}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }
}
