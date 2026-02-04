import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/bg_model.dart';
import '../../providers/bg_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_buttons.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

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
                      gradient: AppColors.purpleGradient,
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
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports & Analytics',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Insights and statistics for your BGs',
                        style: TextStyle(
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
                  PremiumOutlinedButton(
                    text: 'Export PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    color: AppColors.danger,
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppDimensions.spaceXs),
                  GradientButton(
                    text: 'Export Excel',
                    icon: Icons.table_chart_rounded,
                    gradient: AppColors.greenGradient,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // Reports Content
          Expanded(
            child: allBgsAsync.when(
              data: (bgs) => _buildReportsContent(context, bgs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent(BuildContext context, List<BgModel> bgs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Charts
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Status Distribution
              Expanded(
                child: PremiumCard(
                  enableHover: false,
                  padding: const EdgeInsets.all(AppDimensions.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReportSectionHeader(
                        title: 'BG Status Distribution',
                        icon: Icons.pie_chart_rounded,
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      Expanded(child: _buildStatusChart(bgs)),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              ),

              const SizedBox(height: AppDimensions.spaceMd),

              // Amount by Bank
              Expanded(
                child:
                    PremiumCard(
                          enableHover: false,
                          padding: const EdgeInsets.all(AppDimensions.spaceMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _ReportSectionHeader(
                                title: 'Amount by Bank',
                                icon: Icons.account_balance_rounded,
                              ),
                              const SizedBox(height: AppDimensions.spaceMd),
                              Expanded(child: _buildBankChart(bgs)),
                            ],
                          ),
                        )
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppDimensions.spaceMd),

        // Right Column - Quick Reports
        Expanded(
          child: Column(
            children: [
              // Expiry Calendar
              Expanded(
                child:
                    PremiumCard(
                          enableHover: false,
                          padding: const EdgeInsets.all(AppDimensions.spaceMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _ReportSectionHeader(
                                title: 'Upcoming Expiries',
                                icon: Icons.calendar_month_rounded,
                              ),
                              const SizedBox(height: AppDimensions.spaceSm),
                              Expanded(child: _buildExpiryList(bgs)),
                            ],
                          ),
                        )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
              ),

              const SizedBox(height: AppDimensions.spaceMd),

              // Quick Stats
              _buildQuickStatCard(
                    'Average BG Amount',
                    _calculateAvgAmount(bgs),
                    Icons.trending_up_rounded,
                    AppColors.blueGradient,
                  )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppDimensions.spaceMd),

              _buildQuickStatCard(
                    'Total Extensions',
                    bgs
                        .fold<int>(0, (sum, bg) => sum + bg.extensionCount)
                        .toString(),
                    Icons.update_rounded,
                    AppColors.orangeGradient,
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChart(List<BgModel> bgs) {
    final active = bgs
        .where((bg) => bg.status == BgStatus.active && !bg.isExpired)
        .length;
    final expired = bgs.where((bg) => bg.isExpired).length;
    final released = bgs.where((bg) => bg.status == BgStatus.released).length;
    final total = bgs.length;

    if (total == 0) {
      return const Center(child: Text('No data available'));
    }

    return Row(
      children: [
        // Simple pie chart visualization
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      values: [
                        active.toDouble(),
                        expired.toDouble(),
                        released.toDouble(),
                      ],
                      colors: [
                        AppColors.success,
                        AppColors.danger,
                        AppColors.info,
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Total BGs',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Legend
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(
              label: 'Active',
              value: active.toString(),
              color: AppColors.success,
              percentage: (active / total * 100).toStringAsFixed(1),
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            _LegendItem(
              label: 'Expired',
              value: expired.toString(),
              color: AppColors.danger,
              percentage: (expired / total * 100).toStringAsFixed(1),
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            _LegendItem(
              label: 'Released',
              value: released.toString(),
              color: AppColors.info,
              percentage: (released / total * 100).toStringAsFixed(1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankChart(List<BgModel> bgs) {
    final currencyFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 1,
    );

    // Group by bank
    final Map<String, double> bankAmounts = {};
    for (final bg in bgs.where((bg) => bg.status == BgStatus.active)) {
      bankAmounts[bg.bankName] = (bankAmounts[bg.bankName] ?? 0) + bg.amount;
    }

    final sortedBanks = bankAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topBanks = sortedBanks.take(5).toList();

    if (topBanks.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxAmount = topBanks.first.value;

    return Column(
      children: topBanks.asMap().entries.map((entry) {
        final index = entry.key;
        final bank = entry.value;
        final percentage = bank.value / maxAmount;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  bank.key,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceXs),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500 + index * 100),
                      height: 28,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.chartColors[index %
                                AppColors.chartColors.length],
                            AppColors
                                .chartColors[index %
                                    AppColors.chartColors.length]
                                .withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: percentage,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.chartColors[index %
                                    AppColors.chartColors.length],
                                AppColors
                                    .chartColors[index %
                                        AppColors.chartColors.length]
                                    .withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spaceXs),
              SizedBox(
                width: 70,
                child: Text(
                  currencyFormat.format(bank.value),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpiryList(List<BgModel> bgs) {
    final dateFormat = DateFormat('dd MMM');
    final expiringBgs =
        bgs
            .where(
              (bg) =>
                  bg.status == BgStatus.active &&
                  bg.daysUntilExpiry >= 0 &&
                  bg.daysUntilExpiry <= 90,
            )
            .toList()
          ..sort((a, b) => a.currentExpiryDate.compareTo(b.currentExpiryDate));

    if (expiringBgs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 48,
              color: AppColors.success,
            ),
            SizedBox(height: 8),
            Text(
              'No BGs expiring soon',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: expiringBgs.take(6).length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final bg = expiringBgs[index];
        final daysLeft = bg.daysUntilExpiry;

        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.spaceXs),
          padding: const EdgeInsets.all(AppDimensions.spaceSm),
          decoration: BoxDecoration(
            color: daysLeft <= 7
                ? AppColors.dangerLight
                : (daysLeft <= 30
                      ? AppColors.warningLight
                      : AppColors.background),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: daysLeft <= 7
                      ? AppColors.danger
                      : (daysLeft <= 30
                            ? AppColors.warning
                            : AppColors.success),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateFormat.format(bg.currentExpiryDate).split(' ')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dateFormat.format(bg.currentExpiryDate).split(' ')[1],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bg.bgNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      bg.bankName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: daysLeft <= 7
                      ? AppColors.danger
                      : (daysLeft <= 30
                            ? AppColors.warning
                            : AppColors.success),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '$daysLeft days',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return GlassCard(
      opacity: 0.9,
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateAvgAmount(List<BgModel> bgs) {
    final currencyFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 1,
    );
    final activeBgs = bgs.where((bg) => bg.status == BgStatus.active).toList();
    if (activeBgs.isEmpty) return '₹0';
    final avg =
        activeBgs.fold<double>(0, (sum, bg) => sum + bg.amount) /
        activeBgs.length;
    return currencyFormat.format(avg);
  }
}

class _ReportSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ReportSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String percentage;

  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($percentage%)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -90 * 3.14159 / 180;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
