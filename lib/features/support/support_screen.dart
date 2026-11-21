import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/config/api_constants.dart';
import '../../app/theme/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Support', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.headset_mic, color: Colors.white, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('We are here to help!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Contact us 7 days a week for any order or shopping assistance.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact Channels
            _supportCard(
              icon: Icons.chat_bubble_outline,
              color: Colors.green,
              title: 'Chat on WhatsApp',
              subtitle: 'Instant support on WhatsApp: +91 9876543210',
              onTap: () => _launch('https://wa.me/${AppConfig.whatsappNumber}?text=Hi%20Jomiyo%20Mall%20Support'),
            ),
            const SizedBox(height: 12),
            _supportCard(
              icon: Icons.phone_outlined,
              color: AppColors.primary,
              title: 'Call Support Helpline',
              subtitle: AppConfig.supportPhone,
              onTap: () => _launch('tel:${AppConfig.supportPhone}'),
            ),
            const SizedBox(height: 12),
            _supportCard(
              icon: Icons.email_outlined,
              color: AppColors.secondary,
              title: 'Email Helpdesk',
              subtitle: AppConfig.supportEmail,
              onTap: () => _launch('mailto:${AppConfig.supportEmail}?subject=Support%20Request%20Jomiyo%20Mall'),
            ),

            const SizedBox(height: 28),
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _faqTile(
              'How can I track my shipment?',
              'Once your order is dispatched, you will receive a tracking link via SMS/email and can view live shipment progress under "My Orders" in your account.',
            ),
            _faqTile(
              'What payment options are supported?',
              'We support all major payment methods including UPI (Google Pay, PhonePe, Paytm), Credit/Debit cards, Net Banking, and Cash on Delivery.',
            ),
            _faqTile(
              'What is your return & refund policy?',
              'We offer a 7-day hassle-free return and replacement policy for eligible damaged, defective, or incorrect products.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _supportCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
