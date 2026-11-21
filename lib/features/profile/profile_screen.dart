import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/config/api_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../shared/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: auth.isAuthenticated && auth.user != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            auth.user!.displayName.isNotEmpty
                                ? auth.user!.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.user!.displayName.isNotEmpty ? auth.user!.displayName : auth.user!.username,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                auth.user!.email,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                              if (auth.user!.phone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  auth.user!.phone,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.dividerLight,
                          child: Icon(Icons.person_outline, size: 36, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 12),
                        const Text('Sign in for a better experience', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('View orders, track shipments & manage addresses', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'LOGIN',
                                onPressed: () => context.push('/login'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                text: 'REGISTER',
                                isOutlined: true,
                                onPressed: () => context.push('/register'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 14),

            // Account Options Menu
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _tile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    subtitle: 'Track, view, and reorder past purchases',
                    onTap: () => context.push('/orders'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _tile(
                    icon: Icons.favorite_border,
                    title: 'My Wishlist',
                    subtitle: 'Items you have saved for later',
                    onTap: () => context.push('/wishlist'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _tile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Manage delivery addresses and PIN codes',
                    onTap: () => context.push('/checkout'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _tile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Customer Support',
                    subtitle: 'WhatsApp, Call, or Email Jomiyo Mall helpdesk',
                    onTap: () => context.push('/support'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _tile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Theme, policies, version & privacy details',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button if logged in
            if (auth.isAuthenticated)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: const Text('LOGOUT'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to sign out of your account?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              onPressed: () {
                                ref.read(authProvider.notifier).logout();
                                Navigator.pop(ctx);
                              },
                              child: const Text('LOGOUT'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 32),
            const Text(
              'App Version ${AppConfig.appVersion}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondaryLight),
      onTap: onTap,
    );
  }
}
