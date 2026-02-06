import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/bg_model.dart';
import '../../providers/bg_providers.dart';
import '../../widgets/bg_table_row.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/premium_inputs.dart';
import '../../../core/utils/date_utils.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final filteredBgsAsync = ref.watch(filteredBgsProvider);
    final filterState = ref.watch(bgFilterProvider);

    return Container(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filterState.firmFilter != null
                          ? '${filterState.firmFilter} Dashboard'
                          : 'Dashboard',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filterState.firmFilter != null
                          ? 'Bank guarantees for ${filterState.firmFilter}'
                          : 'Overview of your bank guarantees',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Add BG Button
                _AddButton(onPressed: () => _showAddBgDialog(context, ref)),
              ],
            ),

            const SizedBox(height: 24),

            // Stats Cards
            _buildStatsCards(context, ref, stats),

            const SizedBox(height: 24),

            // Filters
            _buildFilters(ref, filterState),

            const SizedBox(height: 20),

            // BG List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Bank Guarantees',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    filteredBgsAsync
                            .whenData(
                              (bgs) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${bgs.length}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .value ??
                        const SizedBox(),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    ref.invalidate(allBgsProvider);
                    ref.invalidate(dashboardStatsProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  tooltip: 'Refresh',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // BG List
            Expanded(
              child: filteredBgsAsync.when(
                data: (bgs) {
                  if (bgs.isEmpty) {
                    return _buildEmptyState(filterState, ref, context);
                  }

                  return ListView.builder(
                    itemCount: bgs.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return BgTableRow(bg: bgs[index], index: index)
                          .animate(delay: Duration(milliseconds: index * 30))
                          .fadeIn(duration: 200.ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  );
                },
                loading: () => ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => const ShimmerTableRow(),
                ),
                error: (error, _) => ErrorStateWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(allBgsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(
    BuildContext context,
    WidgetRef ref,
    DashboardStats stats,
  ) {
    final currencyFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total BGs',
            value: stats.totalBgCount.toString(),
            subtitle: 'Active guarantees',
            icon: Icons.account_balance_rounded,
            gradient: AppColors.blueGradient,
            onTap: () {
              ref
                  .read(bgFilterProvider.notifier)
                  .setFilterType(BgFilterType.active);
            },
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _StatCard(
                    title: 'Expiring Soon',
                    value: stats.expiringBgCount.toString(),
                    subtitle: 'Within 50 days',
                    icon: Icons.schedule_rounded,
                    gradient: AppColors.orangeGradient,
                    onTap: () {
                      ref
                          .read(bgFilterProvider.notifier)
                          .setFilterType(BgFilterType.expiringWithin50Days);
                    },
                  )
                  .animate(delay: 50.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _StatCard(
                    title: 'Released',
                    value: stats.releasedBgCount.toString(),
                    subtitle: 'Completed',
                    icon: Icons.check_circle_outline_rounded,
                    gradient: AppColors.greenGradient,
                    onTap: () {
                      ref
                          .read(bgFilterProvider.notifier)
                          .setFilterType(BgFilterType.released);
                    },
                  )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _StatCard(
                    title: 'Total Value',
                    value: currencyFormat.format(stats.totalBgAmount),
                    subtitle: 'All active BGs',
                    icon: Icons.currency_rupee_rounded,
                    gradient: AppColors.purpleGradient,
                    onTap: () {
                      ref
                          .read(bgFilterProvider.notifier)
                          .setFilterType(BgFilterType.active);
                    },
                  )
                  .animate(delay: 150.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _StatCard(
                    title: 'FDR Value',
                    value: currencyFormat.format(stats.totalFdrAmount),
                    subtitle: 'Against BGs',
                    icon: Icons.savings_outlined,
                    gradient: AppColors.pinkGradient,
                    onTap: () {
                      ref.read(currentScreenProvider.notifier).state =
                          AppScreen.fdrManagement;
                    },
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildFilters(WidgetRef ref, BgFilterState filterState) {
    final bankNamesAsync = ref.watch(bankNamesProvider);
    final discomNamesAsync = ref.watch(discomNamesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChipButton(
            label: 'All',
            isSelected: filterState.filterType == BgFilterType.all,
            onTap: () => ref
                .read(bgFilterProvider.notifier)
                .setFilterType(BgFilterType.all),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Active',
            isSelected: filterState.filterType == BgFilterType.active,
            color: AppColors.success,
            onTap: () => ref
                .read(bgFilterProvider.notifier)
                .setFilterType(BgFilterType.active),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Expiring Soon',
            isSelected:
                filterState.filterType == BgFilterType.expiringWithin50Days,
            color: AppColors.warning,
            onTap: () => ref
                .read(bgFilterProvider.notifier)
                .setFilterType(BgFilterType.expiringWithin50Days),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Expired',
            isSelected: filterState.filterType == BgFilterType.expired,
            color: AppColors.danger,
            onTap: () => ref
                .read(bgFilterProvider.notifier)
                .setFilterType(BgFilterType.expired),
          ),
          const SizedBox(width: 8),
          _FilterChipButton(
            label: 'Released',
            isSelected: filterState.filterType == BgFilterType.released,
            color: AppColors.info,
            onTap: () => ref
                .read(bgFilterProvider.notifier)
                .setFilterType(BgFilterType.released),
          ),

          const SizedBox(width: 16),
          Container(height: 24, width: 1, color: AppColors.border),
          const SizedBox(width: 16),

          // Bank Filter Dropdown
          bankNamesAsync.when(
            data: (banks) => _FilterDropdown(
              label: filterState.bankFilter ?? 'Bank',
              isActive: filterState.bankFilter != null,
              items: ['All Banks', ...banks],
              onSelected: (value) {
                ref
                    .read(bgFilterProvider.notifier)
                    .setBankFilter(value == 'All Banks' ? null : value);
              },
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          const SizedBox(width: 8),

          // Discom Filter Dropdown
          discomNamesAsync.when(
            data: (discoms) => _FilterDropdown(
              label: filterState.discomFilter ?? 'Discom',
              isActive: filterState.discomFilter != null,
              items: ['All Discoms', ...discoms],
              onSelected: (value) {
                ref
                    .read(bgFilterProvider.notifier)
                    .setDiscomFilter(value == 'All Discoms' ? null : value);
              },
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          if (filterState.hasActiveFilters) ...[
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(bgFilterProvider.notifier).clearFilters(),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BgFilterState filterState,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              filterState.hasActiveFilters
                  ? Icons.filter_alt_off_rounded
                  : Icons.account_balance_outlined,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            filterState.hasActiveFilters
                ? 'No matching BGs'
                : AppStrings.noBgsFound,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filterState.hasActiveFilters
                ? 'Try adjusting your filters'
                : AppStrings.noBgsFoundDesc,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (filterState.hasActiveFilters)
            TextButton(
              onPressed: () =>
                  ref.read(bgFilterProvider.notifier).clearFilters(),
              child: const Text('Clear Filters'),
            )
          else
            _AddButton(onPressed: () => _showAddBgDialog(context, ref)),
        ],
      ),
    );
  }

  void _showAddBgDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const AddBgDialog());
  }
}

// Minimal Stat Card - White background with gradient accent
class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppColors.shadowMedium
                    : AppColors.shadowLight,
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -4.0))
              : Matrix4.identity(),
          child: Row(
            children: [
              // Gradient accent strip
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            gradient: widget.gradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Minimal outline filter chip
class _FilterChipButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  State<_FilterChipButton> createState() => _FilterChipButtonState();
}

class _FilterChipButtonState extends State<_FilterChipButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? effectiveColor.withValues(alpha: 0.1)
                : (_isHovered ? AppColors.background : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? effectiveColor
                  : (_isHovered ? AppColors.textMuted : AppColors.border),
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected
                  ? effectiveColor
                  : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Filter dropdown for bank/discom
class _FilterDropdown extends StatelessWidget {
  final String label;
  final bool isActive;
  final List<String> items;
  final Function(String) onSelected;

  const _FilterDropdown({
    required this.label,
    required this.isActive,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
      onSelected: onSelected,
    );
  }
}

// Add button
class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: const Text('Add BG'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

// Add BG Dialog (keeping existing logic but with cleaner design)
class AddBgDialog extends ConsumerStatefulWidget {
  const AddBgDialog({super.key});

  @override
  ConsumerState<AddBgDialog> createState() => _AddBgDialogState();
}

class _AddBgDialogState extends ConsumerState<AddBgDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bgNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _tenderController = TextEditingController();
  final _fdrNumberController = TextEditingController();
  final _fdrAmountController = TextEditingController();
  final _roiController = TextEditingController();

  // Date controllers (format: dd/MM/yyyy)
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _claimExpiryDateController = TextEditingController();
  final _fdrDateController = TextEditingController();

  String? _selectedBank;
  String? _selectedDiscom;
  String _selectedFirm = 'DoonInfra';
  bool _hasFdr = false;

  final List<String> _banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
  ];

  final List<String> _discoms = [
    'UPPCL',
    'PVVNL',
    'DVVNL',
    'MVVNL',
    'PUVVNL',
    'KESCO',
    'TORRENT POWER',
    'TATA POWER',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-select the firm based on current filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final filterState = ref.read(bgFilterProvider);
      if (filterState.firmFilter != null) {
        setState(() {
          _selectedFirm = filterState.firmFilter!;
        });
      }
    });
  }

  @override
  void dispose() {
    _bgNumberController.dispose();
    _amountController.dispose();
    _tenderController.dispose();
    _fdrNumberController.dispose();
    _fdrAmountController.dispose();
    _roiController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _claimExpiryDateController.dispose();
    _fdrDateController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String text) => DateFormatterUtils.parseFlexible(text);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Bank Guarantee',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Enter the BG details below',
                          style: TextStyle(
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
                      foregroundColor: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel(title: 'BG Information'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _bgNumberController,
                              label: 'BG Number',
                              icon: Icons.tag_rounded,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _amountController,
                              label: 'Amount (₹)',
                              icon: Icons.currency_rupee_rounded,
                              required: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: PremiumManualDateField(
                              controller: _issueDateController,
                              label: 'Issue Date',
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PremiumManualDateField(
                              controller: _expiryDateController,
                              label: 'Expiry Date',
                              validator: (v) =>
                                  v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: PremiumManualDateField(
                              controller: _claimExpiryDateController,
                              label: 'Claim Expiry Date',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _tenderController,
                              label: 'Tender Number',
                              icon: Icons.description_outlined,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'Bank Name',
                              _selectedBank,
                              _banks,
                              (value) => setState(() => _selectedBank = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              'Discom',
                              _selectedDiscom,
                              _discoms,
                              (value) =>
                                  setState(() => _selectedDiscom = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Firm selection
                      _buildDropdownField(
                        'Firm',
                        _selectedFirm,
                        availableFirms,
                        (value) => setState(
                          () => _selectedFirm = value ?? 'DoonInfra',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // FDR Toggle
                      Row(
                        children: [
                          const _SectionLabel(title: 'FDR Details'),
                          const Spacer(),
                          Switch(
                            value: _hasFdr,
                            onChanged: (value) =>
                                setState(() => _hasFdr = value),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),

                      if (_hasFdr) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _fdrNumberController,
                                label: 'FDR Number',
                                icon: Icons.savings_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PremiumManualDateField(
                                controller: _fdrDateController,
                                label: 'FDR Date',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _fdrAmountController,
                                label: 'FDR Amount (₹)',
                                icon: Icons.currency_rupee_rounded,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _roiController,
                                label: 'ROI (%)',
                                icon: Icons.percent_rounded,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Add BG'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Required' : null
          : null,
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: '$label *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  void _submitForm() async {
    final issueDate = _parseDate(_issueDateController.text);
    final expiryDate = _parseDate(_expiryDateController.text);
    final claimExpiryDate = _parseDate(_claimExpiryDateController.text);
    final fdrDate = _parseDate(_fdrDateController.text);

    if (_formKey.currentState!.validate() &&
        issueDate != null &&
        expiryDate != null) {
      try {
        // Create FDR if enabled
        FdrModel? fdrDetails;
        if (_hasFdr &&
            _fdrNumberController.text.isNotEmpty &&
            fdrDate != null) {
          fdrDetails = FdrModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fdrNumber: _fdrNumberController.text,
            fdrDate: fdrDate,
            fdrAmount: double.tryParse(_fdrAmountController.text) ?? 0,
            roi: double.tryParse(_roiController.text) ?? 0,
          );
        }

        // Create BG
        final now = DateTime.now();
        final bg = BgModel(
          id: now.millisecondsSinceEpoch.toString(),
          bgNumber: _bgNumberController.text,
          amount: double.tryParse(_amountController.text) ?? 0,
          issueDate: issueDate,
          expiryDate: expiryDate,
          claimExpiryDate: claimExpiryDate ?? expiryDate,
          bankName: _selectedBank ?? '',
          discom: _selectedDiscom ?? '',
          tenderNumber: _tenderController.text,
          status: BgStatus.active,
          fdrDetails: fdrDetails,
          extensionHistory: [],
          documents: [],
          createdAt: now,
          updatedAt: now,
          firmName: _selectedFirm,
        );

        // Save to repository
        final repo = ref.read(bgRepositoryProvider);
        await repo.addBg(bg);

        // Refresh the providers
        ref.invalidate(allBgsProvider);
        ref.invalidate(dashboardStatsProvider);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('BG ${bg.bgNumber} added successfully!'),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
