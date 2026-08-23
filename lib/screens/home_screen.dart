import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_provider.dart';
import '../theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 24),
              _buildSearchBar(context),
              const SizedBox(height: 32),
              _buildStatCardsRow(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Today''s Schedule', 'View All'),
              const SizedBox(height: 16),
              _buildHorizontalSchedule(context),
              const SizedBox(height: 32),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionsRow(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Recent Inquiries', 'View Inquiries'),
              const SizedBox(height: 16),
              _buildRecentInquiriesList(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'GOOD MORNING';
    }
    if (hour < 17) {
      return 'GOOD AFTERNOON';
    }
    if (hour < 20) {
      return 'GOOD EVENING';
    }
    return 'GOOD NIGHT';
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final displayName = user?.displayName ?? 'Prof. Sarah Jenkins';
    final avatarSeed = user?.displayName ?? 'Sarah Jenkins';

    return Row(
      children: [
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) {
            if (value == 'logout') {
              ref.read(authProvider.notifier).logout();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  SizedBox(width: 12),
                  Text('Log out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: ClipOval(
              child: Image.network(
                'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(avatarSeed)}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text(
                  user?.initials ?? 'T',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Search students or records...',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatCardsRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Left Card - Blue
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary, // Vibrant blue
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 16),
                const Text(
                  '124',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total Students',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Right Card - White
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
              ],
              border: isDark ? Border.all(color: Theme.of(context).colorScheme.outlineVariant) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF7ED), // Very light orange background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFF97316), size: 20),
                ),
                const SizedBox(height: 16),
                Text(
                  '98%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Avg Attendance',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          actionText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalSchedule(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildScheduleCard(
            context,
            'UPCOMING',
            const Color(0xFFDBEAFE),
            const Color(0xFF1D4ED8),
            '09:00 AM',
            'Advanced Physics',
            'Room 302, Science Block',
            true, // is active
          ),
          const SizedBox(width: 16),
          _buildScheduleCard(
            context,
            'LATER',
            isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
            '11:00 AM',
            'Quantum Mechanics',
            'Lab B4',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
      BuildContext context, String tag, Color tagBgColor, Color tagTextColor, String time, String title, String subtitle, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
        boxShadow: (isActive && !isDark)
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: tagTextColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
              Text(
                time,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatarGroup(context),
              if (isActive)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarGroup(BuildContext context) {
    return Row(
      children: [
        _buildStackedAvatar(context, 'https://api.dicebear.com/7.x/initials/png?seed=Alex', 0),
        _buildStackedAvatar(context, 'https://api.dicebear.com/7.x/initials/png?seed=B', 1),
        _buildStackedAvatar(context, 'https://api.dicebear.com/7.x/initials/png?seed=C', 2),
        Transform.translate(
          offset: const Offset(-24, 0),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '+24',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedAvatar(BuildContext context, String url, int index) {
    return Transform.translate(
      offset: Offset(-12.0 * index, 0),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(context, 'Attendance', Icons.show_chart_rounded, const Color(0xFFEFF6FF), const Color(0xFF3B82F6)),
        _buildQuickActionItem(context, 'Grades', Icons.assignment_rounded, const Color(0xFFFAF5FF), const Color(0xFFA855F7)), 
        _buildQuickActionItem(context, 'Announce', Icons.campaign_outlined, const Color(0xFFFFF7ED), const Color(0xFFF97316)),
        _buildQuickActionItem(context, 'Events', Icons.calendar_month_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildQuickActionItem(BuildContext context, String label, IconData icon, Color bgColor, Color iconColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: isDark ? Border.all(color: Theme.of(context).colorScheme.outlineVariant) : null,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.15) : bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentInquiriesList(BuildContext context) {
    return Column(
      children: [
        _buildInquiryTile(
          context,
          'Marcus Thorne',
          'Physics 302 • 10m ago',
          'https://api.dicebear.com/7.x/initials/png?seed=Marcus+Thorne',
        ),
        const SizedBox(height: 12),
        _buildInquiryTile(
          context,
          'Lydia Vance',
          'Lab B4 • 2h ago',
          'https://api.dicebear.com/7.x/initials/png?seed=Lydia+Vance',
        ),
      ],
    );
  }

  Widget _buildInquiryTile(BuildContext context, String name, String subtext, String avatarUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
          ),
        ],
      ),
    );
  }
}