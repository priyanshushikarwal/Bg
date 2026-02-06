import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/bg_model.dart';
import '../../providers/bg_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/premium_buttons.dart';
import '../../widgets/bg_expanded_details.dart';
import '../dashboard/dashboard_screen.dart';
import '../../../core/services/bg_report_service.dart';

class BgManagementScreen extends ConsumerWidget {
  const BgManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredBgsAsync = ref.watch(filteredBgsProvider);
    final filterState = ref.watch(bgFilterProvider);

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
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filterState.firmFilter != null
                            ? '${filterState.firmFilter} BGs'
                            : 'BG Management',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        filterState.firmFilter != null
                            ? 'Bank Guarantees for ${filterState.firmFilter}'
                            : 'Manage all your Bank Guarantees',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _exportBgReport(context, filteredBgsAsync, filterState),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('Export List'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    text: 'Add New BG',
                    icon: Icons.add_rounded,
                    onPressed: () => _showAddBgDialog(context),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // Quick Stats
          filteredBgsAsync.when(
            data: (bgs) => _buildQuickStats(bgs),
            loading: () => const SizedBox(height: 80),
            error: (_, __) => const SizedBox(height: 80),
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // Content Grid
          Expanded(
            child: filteredBgsAsync.when(
              data: (bgs) => _buildBgGrid(context, bgs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorStateWidget(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<BgModel> bgs) {
    final active = bgs
        .where((bg) => bg.status == BgStatus.active && !bg.isExpired)
        .length;
    final expiring = bgs.where((bg) => bg.isExpiringWithinDays(30)).length;
    final expired = bgs.where((bg) => bg.isExpired).length;
    final released = bgs.where((bg) => bg.status == BgStatus.released).length;

    return Row(
      children: [
        _QuickStatChip(
          label: 'Active',
          count: active,
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: AppDimensions.spaceMd),
        _QuickStatChip(
          label: 'Expiring',
          count: expiring,
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        ),
        const SizedBox(width: AppDimensions.spaceMd),
        _QuickStatChip(
          label: 'Expired',
          count: expired,
          color: AppColors.danger,
          icon: Icons.error_rounded,
        ),
        const SizedBox(width: AppDimensions.spaceMd),
        _QuickStatChip(
          label: 'Released',
          count: released,
          color: AppColors.info,
          icon: Icons.verified_rounded,
        ),
      ],
    );
  }

  Widget _buildBgGrid(BuildContext context, List<BgModel> bgs) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yy');

    if (bgs.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.account_balance_rounded,
        title: 'No Bank Guarantees',
        description: 'Add your first BG to get started',
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: bgs.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final bg = bgs[index];
        return _CompactBgCard(
              bg: bg,
              currencyFormat: currencyFormat,
              dateFormat: dateFormat,
              onTap: () => _showBgDetailsDialog(context, bg),
            )
            .animate(delay: Duration(milliseconds: index * 30))
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.05, end: 0);
      },
    );
  }

  void _showBgDetailsDialog(BuildContext context, BgModel bg) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bg.bgNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            bg.bankName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Details
              Expanded(child: BgExpandedDetails(bg: bg)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBgDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddBgDialog());
  }

  Future<void> _exportBgReport(
    BuildContext context,
    AsyncValue<List<BgModel>> filteredBgsAsync,
    BgFilterState filterState,
  ) async {
    final bgs = filteredBgsAsync.valueOrNull;
    if (bgs == null || bgs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No bank guarantees to export'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      final firmName = filterState.firmFilter ?? 'All Firms';
      final filePath = await BgReportService.generateBgListReport(
        bgs,
        firmName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved: $filePath'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

class _QuickStatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _QuickStatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.9,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactBgCard extends StatefulWidget {
  final BgModel bg;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _CompactBgCard({
    required this.bg,
    required this.currencyFormat,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  State<_CompactBgCard> createState() => _CompactBgCardState();
}

class _CompactBgCardState extends State<_CompactBgCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.bg;
    final statusColor = _getStatusColor(bg);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? statusColor.withValues(alpha: 0.3)
                  : AppColors.border,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? statusColor.withValues(alpha: 0.08)
                    : AppColors.shadowLight.withValues(alpha: 0.5),
                blurRadius: _isHovered ? 12 : 4,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: statusColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bg.bgNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Bank name
              Text(
                bg.bankName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Amount and expiry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.currencyFormat.format(bg.amount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    widget.dateFormat.format(bg.currentExpiryDate),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: bg.isExpired
                          ? AppColors.danger
                          : (bg.isExpiringWithinDays(30)
                                ? AppColors.warning
                                : AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BgModel bg) {
    if (bg.status == BgStatus.released) return AppColors.info;
    if (bg.isExpired) return AppColors.danger;
    if (bg.isExpiringWithinDays(30)) return AppColors.warning;
    return AppColors.success;
  }
}
