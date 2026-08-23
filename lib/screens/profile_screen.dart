import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/user_model.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/theme_provider.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshProfile();
    });
  }

  void _showEditProfileSheet(UserModel? user) {
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final teacherIdController = TextEditingController(text: user?.teacherId ?? '');
    String selectedDept = (user?.department != null && user!.department!.isNotEmpty)
        ? user.department!
        : 'Mathematics';

    final departments = [
      'Mathematics',
      'Science',
      'English',
      'History',
      'Computer Science',
      'Arts',
      'Physical Education',
      'Social Studies',
      'Physics Dept',
      'Other',
    ];

    if (!departments.contains(selectedDept)) {
      departments.insert(0, selectedDept);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Full Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Phone Number
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Teacher ID
                TextField(
                  controller: teacherIdController,
                  decoration: InputDecoration(
                    labelText: 'Teacher ID',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                // Department Dropdown
                DropdownButtonFormField<String>(
                  value: selectedDept,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    prefixIcon: const Icon(Icons.domain_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: departments.map((dept) {
                    return DropdownMenuItem(value: dept, child: Text(dept));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedDept = val);
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = (user ?? const UserModel()).copyWith(
                        fullName: nameController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        teacherId: teacherIdController.text.trim(),
                        department: selectedDept,
                      );
                      await ref.read(authProvider.notifier).updateUserProfile(updated);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile updated successfully! ✨'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final user = authState.user;

    final displayName = (user?.fullName != null && user!.fullName!.isNotEmpty)
        ? user.fullName!
        : (user?.displayName ?? 'Teacher Profile');
    final department = user?.department;
    final email = (user?.email != null && user!.email!.isNotEmpty)
        ? user.email!
        : 'Not provided';
    final phone = (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty)
        ? user.phoneNumber!
        : 'Not provided';
    final teacherId = (user?.teacherId != null && user!.teacherId!.isNotEmpty)
        ? user.teacherId!
        : 'Not provided';
    final subtitle = (department != null && department.isNotEmpty)
        ? 'Faculty • $department'
        : 'Faculty Member';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine if the toggle is on (Dark Mode)
    final isDarkModeOn = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && isDark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileSheet(user),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(authProvider.notifier).refreshProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Avatar and Basic Info
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditProfileSheet(user),
                      child: Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                                width: 4,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(displayName)}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Theme.of(context).colorScheme.primary,
                                  alignment: Alignment.center,
                                  child: Text(
                                    user?.initials ?? 'T',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Info Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PERSONAL INFORMATION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showEditProfileSheet(user),
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Edit', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoCard(
                      context,
                      children: [
                        _buildInfoRow(Icons.email_outlined, 'Email', email),
                        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                        _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
                        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                        _buildInfoRow(
                            Icons.badge_outlined, 'Teacher ID', teacherId),
                        if (department != null && department.isNotEmpty) ...[
                          Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                          _buildInfoRow(
                              Icons.domain_outlined, 'Department', department),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'PREFERENCES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      context,
                      children: [
                        _buildSwitchRow(
                          Icons.dark_mode_outlined,
                          'Dark Mode',
                          isDarkModeOn,
                          (val) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                        _buildActionRow(
                            Icons.notifications_outlined, 'Notifications', true),
                        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                        _buildActionRow(
                            Icons.security_outlined, 'Privacy & Security', true),
                        Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
                        _buildActionRow(
                            Icons.help_outline, 'Help & Support', true),
                      ],
                    ),

                    const SizedBox(height: 32),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show confirmation dialog before logout
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Cancel',
                                      style:
                                          TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref.read(authProvider.notifier).logout();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0x33EF4444) : const Color(0xFFFEF2F2),
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ? Colors.transparent : const Color(0xFFFECACA)),
                          ),
                        ),
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, bool showChevron) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitchRow(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
