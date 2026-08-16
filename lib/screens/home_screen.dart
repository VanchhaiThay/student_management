import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers/auth_provider.dart';
import '../theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF), // Light, very subtle blue background from mockup
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ref),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 32),
              _buildStatCardsRow(),
              const SizedBox(height: 32),
              _buildSectionTitle('Today''s Schedule', 'View All'),
              const SizedBox(height: 16),
              _buildHorizontalSchedule(),
              const SizedBox(height: 32),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionsRow(),
              const SizedBox(height: 32),
              _buildSectionTitle('Recent Inquiries', 'View Inquiries'),
              const SizedBox(height: 16),
              _buildRecentInquiriesList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
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
          child: const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://api.dicebear.com/7.x/initials/png?seed=Sarah+Jenkins'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'GOOD MORNING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Prof. Sarah Jenkins',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B), size: 24),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slight greyish/blueish background
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search students or records...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatCardsRow() {
    return Row(
      children: [
        // Left Card - Blue
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6), // Vibrant blue
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
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
                const Text(
                  '98%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Avg Attendance',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          actionText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalSchedule() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildScheduleCard(
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
            'LATER',
            const Color(0xFFF1F5F9),
            const Color(0xFF64748B),
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
      String tag, Color tagBgColor, Color tagTextColor, String time, String title, String subtitle, bool isActive) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: isActive
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
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatarGroup(),
              if (isActive)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
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

  Widget _buildAvatarGroup() {
    return Row(
      children: [
        _buildStackedAvatar('https://api.dicebear.com/7.x/initials/png?seed=Alex', 0),
        _buildStackedAvatar('https://api.dicebear.com/7.x/initials/png?seed=B', 1),
        _buildStackedAvatar('https://api.dicebear.com/7.x/initials/png?seed=C', 2),
        Transform.translate(
          offset: const Offset(-24, 0),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text(
              '+24',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStackedAvatar(String url, int index) {
    return Transform.translate(
      offset: Offset(-12.0 * index, 0),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem('Attendance', Icons.show_chart_rounded, const Color(0xFFEFF6FF), const Color(0xFF3B82F6)),
        _buildQuickActionItem('Grades', Icons.assignment_rounded, const Color(0xFFFAF5FF), const Color(0xFFA855F7)), 
        _buildQuickActionItem('Announce', Icons.campaign_outlined, const Color(0xFFFFF7ED), const Color(0xFFF97316)),
        _buildQuickActionItem('Events', Icons.calendar_month_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildQuickActionItem(String label, IconData icon, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
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
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentInquiriesList() {
    return Column(
      children: [
        _buildInquiryTile(
          'Marcus Thorne',
          'Physics 302 • 10m ago',
          'https://api.dicebear.com/7.x/initials/png?seed=Marcus+Thorne',
        ),
        const SizedBox(height: 12),
        _buildInquiryTile(
          'Lydia Vance',
          'Lab B4 • 2h ago',
          'https://api.dicebear.com/7.x/initials/png?seed=Lydia+Vance',
        ),
      ],
    );
  }

  Widget _buildInquiryTile(String name, String subtext, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  subtext,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF64748B), size: 16),
          ),
        ],
      ),
    );
  }
}