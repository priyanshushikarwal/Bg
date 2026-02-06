import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../providers/bg_providers.dart';

class AppSidebar extends ConsumerStatefulWidget {
  const AppSidebar({super.key});

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  @override
  Widget build(BuildContext context) {
    final currentScreen = ref.watch(currentScreenProvider);

    return Container(
      width: AppDimensions.sidebarWidth,
      decoration: const BoxDecoration(color: AppColors.sidebarBackground),
      child: Column(
        children: [
          // Logo Section
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Logo mark
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'BG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Management Suite',
                        style: TextStyle(
                          color: AppColors.textOnDarkMuted.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Firm Selector Section
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
                    child: Text(
                      'SELECT FIRM',
                      style: TextStyle(
                        color: AppColors.textOnDarkMuted.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _FirmSelector(),
                  const SizedBox(height: 16),
                  // Section Label
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
                    child: Text(
                      'MAIN MENU',
                      style: TextStyle(
                        color: AppColors.textOnDarkMuted.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _SidebarItem(
                    icon: Icons.grid_view_rounded,
                    label: AppStrings.dashboard,
                    isSelected: currentScreen == AppScreen.dashboard,
                    onTap: () =>
                        ref.read(currentScreenProvider.notifier).state =
                            AppScreen.dashboard,
                  ),
                  _SidebarItem(
                    icon: Icons.account_balance_rounded,
                    label: AppStrings.bgManagement,
                    isSelected: currentScreen == AppScreen.bgManagement,
                    onTap: () =>
                        ref.read(currentScreenProvider.notifier).state =
                            AppScreen.bgManagement,
                  ),
                  _SidebarItem(
                    icon: Icons.savings_outlined,
                    label: AppStrings.fdrManagement,
                    isSelected: currentScreen == AppScreen.fdrManagement,
                    onTap: () =>
                        ref.read(currentScreenProvider.notifier).state =
                            AppScreen.fdrManagement,
                  ),
                  _SidebarItem(
                    icon: Icons.folder_outlined,
                    label: AppStrings.documents,
                    isSelected: currentScreen == AppScreen.documents,
                    onTap: () =>
                        ref.read(currentScreenProvider.notifier).state =
                            AppScreen.documents,
                  ),
                  _SidebarItem(
                    icon: Icons.bar_chart_rounded,
                    label: AppStrings.reports,
                    isSelected: currentScreen == AppScreen.reports,
                    onTap: () =>
                        ref.read(currentScreenProvider.notifier).state =
                            AppScreen.reports,
                  ),
                ],
              ),
            ),
          ),

          // Bottom User Section
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sidebarSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin',
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'admin@company.com',
                        style: TextStyle(
                          color: AppColors.textOnDarkMuted.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textOnDarkMuted.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.sidebarSurface
                    : (_isHovered
                          ? AppColors.sidebarSurface.withValues(alpha: 0.3)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Gradient indicator for selected
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 3,
                    height: 20,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      gradient: widget.isSelected
                          ? AppColors.primaryGradient
                          : null,
                      color: widget.isSelected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Icon
                  Icon(
                    widget.icon,
                    size: 20,
                    color: widget.isSelected
                        ? AppColors.primary
                        : AppColors.textOnDarkMuted.withValues(
                            alpha: _isHovered ? 0.8 : 0.5,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Label
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.isSelected
                            ? AppColors.textOnDark
                            : AppColors.textOnDarkMuted.withValues(
                                alpha: _isHovered ? 0.9 : 0.7,
                              ),
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Firm Selector Widget
class _FirmSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(bgFilterProvider);
    final firms = ref.watch(firmNamesProvider);
    final selectedFirm = filterState.firmFilter;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.sidebarSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedFirm != null
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "All Firms" option
          _FirmOption(
            name: 'All Firms',
            isSelected: selectedFirm == null,
            onTap: () {
              ref.read(bgFilterProvider.notifier).setFirmFilter(null);
            },
          ),
          // Individual firms
          ...firms.map(
            (firm) => _FirmOption(
              name: firm,
              isSelected: selectedFirm == firm,
              onTap: () {
                ref.read(bgFilterProvider.notifier).setFirmFilter(firm);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FirmOption extends StatefulWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _FirmOption({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FirmOption> createState() => _FirmOptionState();
}

class _FirmOptionState extends State<_FirmOption> {
  bool _isHovered = false;

  IconData _getFirmIcon(String name) {
    switch (name) {
      case 'DoonInfra':
        return Icons.corporate_fare_rounded;
      case 'BI High Power Tech':
        return Icons.bolt_rounded;
      case 'BI':
        return Icons.business_rounded;
      default:
        return Icons.all_inclusive_rounded;
    }
  }

  Color _getFirmColor(String name) {
    switch (name) {
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

  @override
  Widget build(BuildContext context) {
    final firmColor = _getFirmColor(widget.name);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? firmColor.withValues(alpha: 0.15)
                : (_isHovered
                      ? AppColors.sidebarSurface.withValues(alpha: 0.5)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? firmColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getFirmIcon(widget.name),
                  size: 16,
                  color: widget.isSelected
                      ? firmColor
                      : AppColors.textOnDarkMuted.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.name,
                  style: TextStyle(
                    color: widget.isSelected
                        ? AppColors.textOnDark
                        : AppColors.textOnDarkMuted.withValues(
                            alpha: _isHovered ? 0.9 : 0.7,
                          ),
                    fontSize: 12,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isSelected)
                Icon(Icons.check_circle_rounded, size: 16, color: firmColor),
            ],
          ),
        ),
      ),
    );
  }
}
