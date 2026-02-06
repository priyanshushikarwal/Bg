import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/bg_model.dart';
import '../providers/bg_providers.dart';
import 'bg_expanded_details.dart';

class BgTableRow extends ConsumerStatefulWidget {
  final BgModel bg;
  final int index;

  const BgTableRow({super.key, required this.bg, required this.index});

  @override
  ConsumerState<BgTableRow> createState() => _BgTableRowState();
}

class _BgTableRowState extends ConsumerState<BgTableRow>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final _dateFormat = DateFormat('dd MMM yy');

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expandedIds = ref.watch(expandedBgIdsProvider);
    final isExpanded = expandedIds.contains(widget.bg.id);

    if (isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.border.withValues(alpha: _isHovered ? 1 : 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered || isExpanded
                  ? AppColors.shadowMedium
                  : AppColors.shadowLight,
              blurRadius: _isHovered || isExpanded ? 12 : 4,
              offset: Offset(0, _isHovered || isExpanded ? 4 : 2),
            ),
          ],
        ),
        transform: _isHovered && !isExpanded
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        child: Column(
          children: [
            // Main Row
            InkWell(
              onTap: () {
                ref.read(expandedBgIdsProvider.notifier).toggle(widget.bg.id);
              },
              borderRadius: BorderRadius.circular(14),
              hoverColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // BG Icon + Number
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: _getStatusColor(),
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.bg.bgNumber,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      widget.bg.bankName,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.textMuted,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getFirmColor(
                                          widget.bg.firmName,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.bg.firmName,
                                        style: TextStyle(
                                          color: _getFirmColor(
                                            widget.bg.firmName,
                                          ),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (widget.bg.extensionCount > 0) ...[
                                      Container(
                                        width: 3,
                                        height: 3,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: AppColors.textMuted,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '+${widget.bg.extensionCount}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Expanded(
                      child: Text(
                        _currencyFormat.format(widget.bg.amount),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),

                    // Expiry
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dateFormat.format(widget.bg.currentExpiryDate),
                            style: TextStyle(
                              color: _getExpiryColor(),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getExpiryText(),
                            style: TextStyle(
                              color: _getExpiryColor().withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Discom
                    Expanded(
                      child: Text(
                        widget.bg.discom,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Status Pill
                    SizedBox(width: 100, child: _buildStatusPill()),

                    // Expand Arrow
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: isExpanded
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Details
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: BgExpandedDetails(bg: widget.bg),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (widget.bg.status == BgStatus.released) return AppColors.info;
    if (widget.bg.isExpired) return AppColors.danger;
    if (widget.bg.isExpiringWithinDays(50)) return AppColors.warning;
    return AppColors.success;
  }

  Color _getExpiryColor() {
    if (widget.bg.status == BgStatus.released) return AppColors.textMuted;
    if (widget.bg.isExpired) return AppColors.danger;
    if (widget.bg.isExpiringWithinDays(30)) return AppColors.warning;
    if (widget.bg.isExpiringWithinDays(50)) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _getExpiryText() {
    if (widget.bg.status == BgStatus.released) return 'Released';
    if (widget.bg.isExpired) return 'Expired';
    final days = widget.bg.daysUntilExpiry;
    return '$days days left';
  }

  Widget _buildStatusPill() {
    final color = _getStatusColor();
    final text = _getStatusText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (widget.bg.status == BgStatus.released) return 'Released';
    if (widget.bg.isExpired) return 'Expired';
    if (widget.bg.isExpiringWithinDays(50)) return 'Expiring';
    return 'Active';
  }

  Color _getFirmColor(String firmName) {
    switch (firmName) {
      case 'DoonInfra':
        return const Color(0xFF6366F1);
      case 'BI High Power Tech':
        return const Color(0xFFF59E0B);
      case 'BI':
        return const Color(0xFF10B981);
      default:
        return AppColors.primary;
    }
  }
}

class BgTableHeader extends StatelessWidget {
  const BgTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _HeaderLabel('BG Details')),
          Expanded(child: _HeaderLabel('Amount')),
          Expanded(child: _HeaderLabel('Expiry')),
          Expanded(child: _HeaderLabel('Discom')),
          const SizedBox(width: 100, child: _HeaderLabel('Status')),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String text;
  const _HeaderLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
