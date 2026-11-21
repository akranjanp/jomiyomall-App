import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/config/api_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/providers/app_providers.dart';

class JomiyoDrawer extends ConsumerWidget {
  const JomiyoDrawer({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final cleanNumber = AppConfig.whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUri = Uri.parse('https://wa.me/$cleanNumber?text=Hello%20Jomiyo%20Mall%20Support,%20I%20have%20an%20inquiry.');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp. Support: +91 9910403750')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Dynamic Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF002275)],
              ),
            ),
            child: auth.isAuthenticated && auth.user != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.secondary,
                              child: Text(
                                auth.user!.displayName.isNotEmpty
                                    ? auth.user!.displayName[0].toUpperCase()
                                    : 'J',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auth.user!.displayName.isNotEmpty ? auth.user!.displayName : auth.user!.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  auth.user!.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'JOMIYO MALL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Welcome, Shopper!',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push('/login');
                          },
                          icon: const Icon(Icons.login_rounded, size: 16, color: AppColors.primary),
                          label: const Text(
                            'SIGN IN / REGISTER',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Drawer Scrollable List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Quick Home
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
                  title: const Text('Home', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                ),

                // My Orders
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 22),
                  title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondaryLight),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/orders');
                  },
                ),

                // Wishlist
                ListTile(
                  leading: const Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 22),
                  title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondaryLight),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/wishlist');
                  },
                ),

                const Divider(height: 16),

                // Shop By Categories Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'SHOP BY CATEGORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),

                // Dynamic Categories
                categoriesAsync.when(
                  data: (categories) => Column(
                    children: categories.take(6).map((cat) {
                      return ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.label_outline_rounded, size: 16, color: AppColors.primary),
                        ),
                        title: Text(cat.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        trailing: Text('${cat.count}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/products?categoryId=${cat.id}&title=${Uri.encodeComponent(cat.name)}');
                        },
                      );
                    }).toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                ListTile(
                  dense: true,
                  leading: const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.primary),
                  title: const Text('View All Categories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/categories');
                  },
                ),

                const Divider(height: 16),

                // Customer Support Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'HELP & SUPPORT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),

                // WhatsApp Support (Direct)
                ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 18),
                  ),
                  title: const Text('WhatsApp Chat Support', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Direct 24/7 assistance', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textSecondaryLight),
                  onTap: () => _openWhatsApp(context),
                ),

                // Phone Support
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.phone_in_talk_outlined, color: AppColors.primary, size: 20),
                  title: const Text('Call Us: +91 9910403750', style: TextStyle(fontSize: 13)),
                  onTap: () => _launchUrl('tel:+919910403750'),
                ),

                // Multi-Vendor WCFM Marketplace
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.storefront_outlined, color: AppColors.secondary, size: 20),
                  title: const Text('Become a Seller', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Start selling on Jomiyo Mall', style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textSecondaryLight),
                  onTap: () => _launchUrl('https://jomiyomall.com/store-manager/'),
                ),

                const Divider(height: 16),

                // App Policies
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textSecondaryLight, size: 20),
                  title: const Text('Privacy Policy', style: TextStyle(fontSize: 12)),
                  onTap: () => _launchUrl(AppConfig.privacyPolicyUrl),
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.description_outlined, color: AppColors.textSecondaryLight, size: 20),
                  title: const Text('Terms of Service', style: TextStyle(fontSize: 12)),
                  onTap: () => _launchUrl(AppConfig.termsUrl),
                ),

                // Logout if authenticated
                if (auth.isAuthenticated) ...[
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
                    title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14)),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully.')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          // Drawer Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: AppColors.backgroundLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jomiyo Mall v1.0.0',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                ),
                Text(
                  '₹ INR Currency',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
