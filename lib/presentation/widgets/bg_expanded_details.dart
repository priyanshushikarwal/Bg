import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/bg_model.dart';
import '../providers/bg_providers.dart';
import 'premium_inputs.dart';
import '../../core/utils/date_utils.dart';

class BgExpandedDetails extends ConsumerStatefulWidget {
  final BgModel bg;

  const BgExpandedDetails({super.key, required this.bg});

  @override
  ConsumerState<BgExpandedDetails> createState() => _BgExpandedDetailsState();
}

class _BgExpandedDetailsState extends ConsumerState<BgExpandedDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          // Action Buttons Row
          Row(
            children: [
              // Extension count badge
              if (widget.bg.extensionHistory.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.update_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Extended ${widget.bg.extensionHistory.length}x',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              // Actions
              _ActionButton(
                icon: Icons.update_rounded,
                label: 'Extend',
                color: AppColors.primary,
                onPressed: widget.bg.status == BgStatus.active
                    ? () => _showExtendDialog(context)
                    : null,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.upload_file_rounded,
                label: 'Upload',
                color: AppColors.info,
                onPressed: () => _showUploadDialog(context),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.check_circle_outline_rounded,
                label: 'Release',
                color: AppColors.success,
                filled: true,
                onPressed: widget.bg.status == BgStatus.active
                    ? () => _showReleaseDialog(context)
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tab Bar - Clean and minimal
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'FDR Details'),
                Tab(text: 'Extensions'),
                Tab(text: 'Documents'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Content - Fixed height
          SizedBox(
            height: 240,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildFdrTab(),
                _buildExtensionsTab(),
                _buildDocumentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BG Info Card
          Expanded(
            child: _InfoCard(
              title: 'BG Information',
              children: [
                _InfoItem(label: 'BG Number', value: widget.bg.bgNumber),
                _InfoItem(
                  label: 'Issue Date',
                  value: dateFormat.format(widget.bg.issueDate),
                ),
                _InfoItem(
                  label: 'Amount',
                  value: currencyFormat.format(widget.bg.amount),
                  valueColor: AppColors.success,
                ),
                _InfoItem(label: 'Bank', value: widget.bg.bankName),
                _InfoItem(label: 'Tender No.', value: widget.bg.tenderNumber),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Expiry Info Card
          Expanded(
            child: _InfoCard(
              title: 'Expiry & Status',
              children: [
                _InfoItem(
                  label: 'Current Expiry',
                  value: dateFormat.format(widget.bg.currentExpiryDate),
                  valueColor: widget.bg.isExpired ? AppColors.danger : null,
                ),
                _InfoItem(
                  label: 'Claim Expiry',
                  value: dateFormat.format(widget.bg.currentClaimExpiryDate),
                ),
                _InfoItem(
                  label: 'Days Remaining',
                  value: widget.bg.isExpired
                      ? 'Expired'
                      : '${widget.bg.daysUntilExpiry} days',
                  valueColor: widget.bg.isExpired
                      ? AppColors.danger
                      : (widget.bg.daysUntilExpiry <= 50
                            ? AppColors.warning
                            : AppColors.success),
                ),
                _InfoItem(label: 'Discom', value: widget.bg.discom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFdrTab() {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    if (widget.bg.fdrDetails == null) {
      return _EmptyTabState(
        icon: Icons.savings_outlined,
        title: 'No FDR Linked',
        subtitle: 'Link an FDR to this bank guarantee',
        actionLabel: 'Link FDR',
        onAction: () => _showLinkFdrDialog(context),
      );
    }

    final fdr = widget.bg.fdrDetails!;
    return SingleChildScrollView(
      child: _InfoCard(
        title: 'Fixed Deposit Receipt',
        children: [
          _InfoItem(label: 'FDR Number', value: fdr.fdrNumber),
          _InfoItem(label: 'FDR Date', value: dateFormat.format(fdr.fdrDate)),
          _InfoItem(
            label: 'FDR Amount',
            value: currencyFormat.format(fdr.fdrAmount),
            valueColor: AppColors.success,
          ),
          _InfoItem(
            label: 'Rate of Interest',
            value: '${fdr.roi}%',
            valueColor: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionsTab() {
    final dateFormat = DateFormat('dd MMM yyyy');

    if (widget.bg.extensionHistory.isEmpty) {
      return _EmptyTabState(
        icon: Icons.history_rounded,
        title: 'No Extensions',
        subtitle: 'This BG has not been extended yet',
        actionLabel: widget.bg.status == BgStatus.active ? 'Extend Now' : null,
        onAction: widget.bg.status == BgStatus.active
            ? () => _showExtendDialog(context)
            : null,
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.bg.extensionHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final ext = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extension on ${dateFormat.format(ext.extensionDate)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'New Expiry: ${dateFormat.format(ext.newBgExpiryDate)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (ext.remarks != null && ext.remarks!.isNotEmpty)
                  Tooltip(
                    message: ext.remarks!,
                    child: Icon(
                      Icons.notes_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    final dateFormat = DateFormat('dd MMM yyyy');

    if (widget.bg.documents.isEmpty) {
      return _EmptyTabState(
        icon: Icons.folder_open_rounded,
        title: 'No Documents',
        subtitle: 'Upload documents for this BG',
        actionLabel: 'Upload Document',
        onAction: () => _showUploadDialog(context),
      );
    }

    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: widget.bg.documents.map((doc) {
          return Container(
            width: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'v${doc.version}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  doc.typeDisplayName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(doc.uploadDate),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showExtendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ExtendBgDialog(bg: widget.bg, ref: ref),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _UploadDocumentDialog(bg: widget.bg, ref: ref),
    );
  }

  void _showLinkFdrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LinkFdrDialog(bg: widget.bg, ref: ref),
    );
  }

  void _showReleaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Release BG'),
        content: Text(
          'Are you sure you want to release BG ${widget.bg.bgNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final repo = ref.read(bgRepositoryProvider);
              final updatedBg = widget.bg.copyWith(status: BgStatus.released);
              await repo.updateBg(updatedBg);
              ref.invalidate(allBgsProvider);
              ref.invalidate(dashboardStatsProvider);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Release'),
          ),
        ],
      ),
    );
  }
}

// Action Button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// Info Card
class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// Info Item
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Empty Tab State
class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyTabState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

// Extend BG Dialog
class _ExtendBgDialog extends StatefulWidget {
  final BgModel bg;
  final WidgetRef ref;

  const _ExtendBgDialog({required this.bg, required this.ref});

  @override
  State<_ExtendBgDialog> createState() => _ExtendBgDialogState();
}

class _ExtendBgDialogState extends State<_ExtendBgDialog> {
  final _expiryDateController = TextEditingController();
  final _claimExpiryDateController = TextEditingController();
  final _remarksController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _expiryDateController.dispose();
    _claimExpiryDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String text) => DateFormatterUtils.parseFlexible(text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Extend BG'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumManualDateField(
              controller: _expiryDateController,
              label: 'New BG Expiry Date',
            ),
            const SizedBox(height: 16),
            PremiumManualDateField(
              controller: _claimExpiryDateController,
              label: 'New Claim Expiry Date',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarksController,
              decoration: InputDecoration(
                labelText: 'Remarks (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 2,
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
          onPressed:
              _expiryDateController.text.isNotEmpty &&
                  _claimExpiryDateController.text.isNotEmpty &&
                  !_isLoading
              ? _submit
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
              : const Text('Extend'),
        ),
      ],
    );
  }

  void _submit() async {
    final newExpiryDate = _parseDate(_expiryDateController.text);
    final newClaimExpiryDate = _parseDate(_claimExpiryDateController.text);

    if (newExpiryDate == null || newClaimExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid date format. Use DD/MM/YYYY'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final extension = ExtensionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        extensionDate: DateTime.now(),
        newBgExpiryDate: newExpiryDate,
        newClaimExpiryDate: newClaimExpiryDate,
        remarks: _remarksController.text.isNotEmpty
            ? _remarksController.text
            : null,
      );
      final repo = widget.ref.read(bgRepositoryProvider);
      final updatedBg = widget.bg.copyWith(
        extensionHistory: [...widget.bg.extensionHistory, extension],
        expiryDate: extension.newBgExpiryDate,
        claimExpiryDate: extension.newClaimExpiryDate,
      );
      await repo.updateBg(updatedBg);
      widget.ref.invalidate(allBgsProvider);
      widget.ref.invalidate(dashboardStatsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
    }
    setState(() => _isLoading = false);
  }
}

// Upload Document Dialog
class _UploadDocumentDialog extends StatefulWidget {
  final BgModel bg;
  final WidgetRef ref;

  const _UploadDocumentDialog({required this.bg, required this.ref});

  @override
  State<_UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<_UploadDocumentDialog> {
  DocumentType? _selectedType;
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Upload Document'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<DocumentType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Document Type',
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
                            Icon(
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
          onPressed:
              _selectedType != null && _selectedFilePath != null && !_isLoading
              ? _submit
              : null,
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

  void _submit() async {
    setState(() => _isLoading = true);
    try {
      final existingDocs = widget.bg.documents
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
      final repo = widget.ref.read(bgRepositoryProvider);
      final updatedBg = widget.bg.copyWith(
        documents: [...widget.bg.documents, doc],
      );
      await repo.updateBg(updatedBg);
      widget.ref.invalidate(allBgsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
    }
    setState(() => _isLoading = false);
  }
}

// Link FDR Dialog
class _LinkFdrDialog extends StatefulWidget {
  final BgModel bg;
  final WidgetRef ref;

  const _LinkFdrDialog({required this.bg, required this.ref});

  @override
  State<_LinkFdrDialog> createState() => _LinkFdrDialogState();
}

class _LinkFdrDialogState extends State<_LinkFdrDialog> {
  final _fdrNumberController = TextEditingController();
  final _fdrAmountController = TextEditingController();
  final _roiController = TextEditingController();
  final _fdrDateController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fdrNumberController.dispose();
    _fdrAmountController.dispose();
    _roiController.dispose();
    _fdrDateController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String text) => DateFormatterUtils.parseFlexible(text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Link FDR'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fdrNumberController,
              decoration: InputDecoration(
                labelText: 'FDR Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            PremiumManualDateField(
              controller: _fdrDateController,
              label: 'FDR Date',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fdrAmountController,
              decoration: InputDecoration(
                labelText: 'FDR Amount (₹)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roiController,
              decoration: InputDecoration(
                labelText: 'ROI (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
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
            backgroundColor: AppColors.primary,
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
              : const Text('Link FDR'),
        ),
      ],
    );
  }

  bool _canSubmit() =>
      _fdrNumberController.text.isNotEmpty &&
      _fdrDateController.text.isNotEmpty &&
      _fdrAmountController.text.isNotEmpty &&
      _roiController.text.isNotEmpty;

  void _submit() async {
    final fdrDate = _parseDate(_fdrDateController.text);
    if (fdrDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid date format. Use DD/MM/YYYY'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final fdr = FdrModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fdrNumber: _fdrNumberController.text,
        fdrDate: fdrDate,
        fdrAmount: double.parse(_fdrAmountController.text),
        roi: double.parse(_roiController.text),
      );
      final repo = widget.ref.read(bgRepositoryProvider);
      final updatedBg = widget.bg.copyWith(fdrDetails: fdr);
      await repo.updateBg(updatedBg);
      widget.ref.invalidate(allBgsProvider);
      widget.ref.invalidate(dashboardStatsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
    }
    setState(() => _isLoading = false);
  }
}
