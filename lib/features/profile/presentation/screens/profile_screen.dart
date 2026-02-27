import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../capacity_building/presentation/providers/capacity_building_provider.dart';
import '../../../events/presentation/providers/invitations_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final modulesState = ref.watch(modulesProvider);
    final completedCount =
        modulesState.modules.where((m) => m.isCompleted).length;
    final invitationsState = ref.watch(invitationsProvider);
    final pendingInvites = invitationsState.pendingCount;

    ref.listen(userProvider, (previous, next) {
      if (next.error == 'Not authenticated') {
        // Token invalid or expired, force logout/login
        context.go('/login');
      }
    });

    // Check current state in case it's already error
    if (userState.error == 'Not authenticated') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userState.error!,
                        style: const TextStyle(color: AppTheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(userProvider.notifier).fetchUser(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileHeader(user, completedCount),
                      const SizedBox(height: 32),
                      _buildProfileDetails(user),
                      const SizedBox(height: 32),
                      _buildActions(context, ref, pendingInvites),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(User? user, int certificateCount) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primary,
          backgroundImage:
              user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
          child: user?.avatarUrl == null
              ? Text(
                  user?.initials ?? "U",
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? "User",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.text,
          ),
        ),
        if (certificateCount > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium,
                    size: 14, color: Colors.amber.shade800),
                const SizedBox(width: 4),
                Text(
                  "$certificateCount ${certificateCount == 1 ? 'Certificate' : 'Certificates'} Earned",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          user?.email ?? "",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        if (user?.userType == 'guest') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.people, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  "Invited Guest",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ] else if (user?.userType == 'exporter') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.success, Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.success.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_user, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  "Verified Exporter",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileDetails(User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailItem(Icons.phone, "Phone", user?.phone ?? "Not set"),
          const Divider(),
          _buildDetailItem(
              Icons.business, "Company", user?.company ?? "Not set"),
          const Divider(),
          _buildDetailItem(Icons.info_outline, "Bio", user?.bio ?? "No bio"),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: AppTheme.text),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
      BuildContext context, WidgetRef ref, int pendingInvites) {
    final user = ref.read(userProvider).user;
    final isStaff = user?.isStaff ?? false;

    return Column(
      children: [
        if (isStaff) ...[
          ListTile(
            onTap: () {
              context.push('/staff/scan');
            },
            leading: const Icon(Icons.qr_code_scanner, color: AppTheme.text),
            title: const Text("Scan Ticket (Staff)"),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.white,
          ),
          const SizedBox(height: 12),
        ],
        ListTile(
          onTap: () {
            context.push('/profile/invitations');
          },
          leading: Stack(
            children: [
              const Icon(Icons.mail, color: AppTheme.primary),
              if (pendingInvites > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$pendingInvites',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          title: const Text("My Invitations"),
          trailing: const Icon(Icons.chevron_right),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
        ),
        const SizedBox(height: 12),
        ListTile(
          onTap: () {
            context.push('/resources?category=certificates');
          },
          leading: const Icon(Icons.workspace_premium, color: Colors.amber),
          title: const Text("My Certificates"),
          trailing: const Icon(Icons.chevron_right),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
        ),
        const SizedBox(height: 12),
        ListTile(
          onTap: () {
            // TODO: Implement Edit Profile
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Edit Profile feature coming soon")),
            );
          },
          leading: const Icon(Icons.edit, color: AppTheme.text),
          title: const Text("Edit Profile"),
          trailing: const Icon(Icons.chevron_right),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
        ),
        const SizedBox(height: 12),
        ListTile(
          onTap: () => ref.read(authProvider.notifier).logout(),
          leading: const Icon(Icons.logout, color: AppTheme.error),
          title: const Text(
            "Logout",
            style: TextStyle(color: AppTheme.error),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
        ),
      ],
    );
  }
}
