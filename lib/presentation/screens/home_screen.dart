import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/bg_providers.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/custom_app_bar.dart';
import 'dashboard/dashboard_screen.dart';
import 'bg_management/bg_management_screen.dart';
import 'fdr_management/fdr_management_screen.dart';
import 'documents/documents_screen.dart';
import 'reports/reports_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          const AppSidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                CustomAppBar(title: _getScreenTitle(currentScreen)),

                // Screen Content
                Expanded(child: _buildScreen(currentScreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle(AppScreen screen) {
    switch (screen) {
      case AppScreen.dashboard:
        return 'Dashboard';
      case AppScreen.bgManagement:
        return 'BG Management';
      case AppScreen.fdrManagement:
        return 'FDR Management';
      case AppScreen.documents:
        return 'Documents';
      case AppScreen.reports:
        return 'Reports';
    }
  }

  Widget _buildScreen(AppScreen screen) {
    switch (screen) {
      case AppScreen.dashboard:
        return const DashboardScreen();
      case AppScreen.bgManagement:
        return const BgManagementScreen();
      case AppScreen.fdrManagement:
        return const FdrManagementScreen();
      case AppScreen.documents:
        return const DocumentsScreen();
      case AppScreen.reports:
        return const ReportsScreen();
    }
  }
}
