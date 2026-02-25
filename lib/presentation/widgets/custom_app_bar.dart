import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../providers/bg_providers.dart';
import '../providers/auth_provider.dart';

class CustomAppBar extends ConsumerWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),

          // Search Bar
          _SearchField(
            onChanged: (query) {
              ref.read(bgFilterProvider.notifier).setSearchQuery(query);
            },
          ),

          const SizedBox(width: 16),

          // Notification Button
          _IconButton(
            icon: Icons.notifications_none_rounded,
            badge: true,
            onPressed: () => _showNotificationsDialog(context),
          ),

          const SizedBox(width: 8),

          // Profile Button
          _ProfileAvatar(),

          if (actions != null) ...[const SizedBox(width: 12), ...actions!],
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          height: 280,
          child: Column(
            children: [
              _NotificationItem(
                icon: Icons.warning_amber_rounded,
                iconColor: AppColors.warning,
                title: '3 BGs expiring soon',
                subtitle: 'Within next 30 days',
                time: '2 hours ago',
              ),
              const Divider(height: 20),
              _NotificationItem(
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.success,
                title: 'BG/2024/001 extended',
                subtitle: 'New expiry: 15 Jun 2024',
                time: '1 day ago',
              ),
              const Divider(height: 20),
              _NotificationItem(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.info,
                title: 'System update',
                subtitle: 'New features available',
                time: '3 days ago',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Mark all read'),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search BGs, banks...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback onPressed;

  const _IconButton({
    required this.icon,
    this.badge = false,
    required this.onPressed,
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  widget.icon,
                  color: _isHovered
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              if (widget.badge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseService.currentUser;
    final email = user?.email ?? 'User';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Logged in as',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.danger,
              ),
              const SizedBox(width: 10),
              Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.danger,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'logout') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Sign Out',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: Text(
                'Are you sure you want to sign out?',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel', style: GoogleFonts.inter()),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await ref.read(authNotifierProvider.notifier).signOut();
          }
        }
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
