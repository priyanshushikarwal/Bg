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
import '../../widgets/premium_inputs.dart';
import '../../../core/utils/date_utils.dart';

class FdrManagementScreen extends ConsumerWidget {
  const FdrManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      gradient: AppColors.pinkGradient,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPink.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FDR Management',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Fixed Deposits linked to Bank Guarantees',
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
                text: 'Add FDR',
                icon: Icons.add_rounded,
                gradient: AppColors.pinkGradient,
                onPressed: () => _showAddFdrDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // FDR Summary
          allBgsAsync.when(
            data: (bgs) => _buildFdrSummary(bgs),
            loading: () => const SizedBox(height: 140),
            error: (_, __) => const SizedBox(height: 140),
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // FDR List
          Expanded(
            child: allBgsAsync.when(
              data: (bgs) => _buildFdrList(context, bgs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorStateWidget(message: error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFdrSummary(List<BgModel> bgs) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final bgsWithFdr = bgs.where((bg) => bg.fdrDetails != null).toList();
    final totalFdrAmount = bgsWithFdr.fold<double>(
      0,
      (sum, bg) => sum + (bg.fdrDetails?.fdrAmount ?? 0),
    );
    final avgRoi = bgsWithFdr.isNotEmpty
        ? bgsWithFdr.fold<double>(
                0,
                (sum, bg) => sum + (bg.fdrDetails?.roi ?? 0),
              ) /
              bgsWithFdr.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: GradientStatCard(
            title: 'Total FDRs',
            value: bgsWithFdr.length.toString(),
            subtitle: 'Linked to BGs',
            icon: Icons.savings_rounded,
            gradient: AppColors.blueGradient,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: AppDimensions.spaceMd),
        Expanded(
          child:
              GradientStatCard(
                    title: 'Total FDR Value',
                    value: currencyFormat.format(totalFdrAmount),
                    subtitle: 'Invested Amount',
                    icon: Icons.currency_rupee_rounded,
                    gradient: AppColors.greenGradient,
                  )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: AppDimensions.spaceMd),
        Expanded(
          child:
              GradientStatCard(
                    title: 'Average ROI',
                    value: '${avgRoi.toStringAsFixed(1)}%',
                    subtitle: 'Across all FDRs',
                    icon: Icons.trending_up_rounded,
                    gradient: AppColors.purpleGradient,
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: AppDimensions.spaceMd),
        Expanded(
          child:
              GradientStatCard(
                    title: 'BGs without FDR',
                    value: (bgs.length - bgsWithFdr.length).toString(),
                    subtitle: 'Consider linking',
                    icon: Icons.link_off_rounded,
                    gradient: AppColors.orangeGradient,
                  )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildFdrList(BuildContext context, List<BgModel> bgs) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');
    final bgsWithFdr = bgs.where((bg) => bg.fdrDetails != null).toList();

    if (bgsWithFdr.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.savings_outlined,
        title: 'No FDRs Found',
        description: 'Link an FDR to a Bank Guarantee to see it here',
      );
    }

    return PremiumCard(
      enableHover: false,
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.pinkGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  Icons.list_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'FDR Details',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${bgsWithFdr.length} records',
                  style: const TextStyle(
                    color: AppColors.primaryPink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMd,
              vertical: AppDimensions.spaceSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'FDR Number',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Linked BG',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ROI',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXs),
          Expanded(
            child: ListView.builder(
              itemCount: bgsWithFdr.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final bg = bgsWithFdr[index];
                final fdr = bg.fdrDetails!;

                return Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spaceXs,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceMd,
                        vertical: AppDimensions.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.pinkGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.savings_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    fdr.fdrNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              bg.bgNumber,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              dateFormat.format(fdr.fdrDate),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              currencyFormat.format(fdr.fdrAmount),
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Text(
                                '${fdr.roi}%',
                                style: const TextStyle(
                                  color: AppColors.info,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            child: bg.status == BgStatus.active
                                ? StatusBadge.active()
                                : StatusBadge.released(),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: Duration(milliseconds: index * 50))
                    .fadeIn()
                    .slideX(
                      begin: 0.05,
                      end: 0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 200),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFdrDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddFdrDialog(ref: ref),
    );
  }
}

class _AddFdrDialog extends StatefulWidget {
  final WidgetRef ref;

  const _AddFdrDialog({required this.ref});

  @override
  State<_AddFdrDialog> createState() => _AddFdrDialogState();
}

class _AddFdrDialogState extends State<_AddFdrDialog> {
  final _fdrNumberController = TextEditingController();
  final _fdrAmountController = TextEditingController();
  final _roiController = TextEditingController();
  final _fdrDateController = TextEditingController();
  String? _selectedBgId;
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
    final allBgsAsync = widget.ref.watch(allBgsProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Link FDR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'Link FDR to an existing BG',
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
                final bgsWithoutFdr = bgs
                    .where(
                      (bg) =>
                          bg.fdrDetails == null && bg.status == BgStatus.active,
                    )
                    .toList();
                if (bgsWithoutFdr.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.warning),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'All active BGs already have FDRs linked',
                            style: TextStyle(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  value: _selectedBgId,
                  decoration: InputDecoration(
                    labelText: 'Select BG *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: bgsWithoutFdr
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
            TextField(
              controller: _fdrNumberController,
              decoration: InputDecoration(
                labelText: 'FDR Number *',
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fdrAmountController,
                    decoration: InputDecoration(
                      labelText: 'FDR Amount (₹) *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _roiController,
                    decoration: InputDecoration(
                      labelText: 'ROI (%) *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
            backgroundColor: AppColors.primaryPink,
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

  bool _canSubmit() {
    return _selectedBgId != null &&
        _fdrNumberController.text.isNotEmpty &&
        _fdrDateController.text.isNotEmpty &&
        _fdrAmountController.text.isNotEmpty &&
        _roiController.text.isNotEmpty;
  }

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
      final allBgs = widget.ref.read(allBgsProvider).value ?? [];
      final selectedBg = allBgs.firstWhere((bg) => bg.id == _selectedBgId);

      final fdr = FdrModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fdrNumber: _fdrNumberController.text,
        fdrDate: fdrDate,
        fdrAmount: double.parse(_fdrAmountController.text),
        roi: double.parse(_roiController.text),
      );

      final updatedBg = selectedBg.copyWith(
        fdrDetails: fdr,
        updatedAt: DateTime.now(),
      );

      final repo = widget.ref.read(bgRepositoryProvider);
      await repo.updateBg(updatedBg);

      widget.ref.invalidate(allBgsProvider);
      widget.ref.invalidate(dashboardStatsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'FDR ${fdr.fdrNumber} linked to ${selectedBg.bgNumber}',
            ),
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
