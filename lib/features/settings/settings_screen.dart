import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/config/api_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('Preferences'),
          _tile(
            icon: Icons.notifications_none,
            title: 'Push Notifications',
            subtitle: 'Order updates and promotional offers',
            trailing: Switch(value: true, activeColor: AppColors.primary, onChanged: (_) {}),
          ),
          _tile(
            icon: Icons.language,
            title: 'App Language',
            subtitle: 'English (Default)',
            onTap: () {},
          ),

          const SizedBox(height: 16),
          _sectionHeader('Legal & Compliance'),
          _tile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we collect and protect your data',
            onTap: () => _openUrl(AppConfig.privacyPolicyUrl),
          ),
          _tile(
            icon: Icons.description_outlined,
            title: 'Terms and Conditions',
            subtitle: 'Store terms of service',
            onTap: () => _openUrl(AppConfig.termsUrl),
          ),
          _tile(
            icon: Icons.replay_outlined,
            title: 'Return and Refund Policy',
            subtitle: '7-day replacement and return rules',
            onTap: () => _openUrl(AppConfig.refundPolicyUrl),
          ),

          const SizedBox(height: 16),
          _sectionHeader('Data & Storage'),
          _tile(
            icon: Icons.cleaning_services_outlined,
            title: 'Clear Cache',
            subtitle: 'Free up local cached product images',
            onTap: () {
              ref.read(localStorageProvider).clearRecentSearches();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App cache cleared successfully.')),
              );
            },
          ),

          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Text('Jomiyo Mall', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Version ${AppConfig.appVersion} (Production)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimaryLight, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondaryLight),
        onTap: onTap,
      ),
    );
  }
}
