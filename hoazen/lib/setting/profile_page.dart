import 'package:flutter/material.dart';
import 'package:hoazen/shared/checkin_common.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF42624B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: ZenColors.mintCard,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ZenColors.headerGreen,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Jess',
                                style: TextStyle(
                                  color: ZenColors.textGreen,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'jess@example.com',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Personalize your experience with quiet reminders, journal settings, and theme details.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Account',
                style: TextStyle(
                  color: ZenColors.textGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.person_outline,
                title: 'Display name',
                value: 'Jess',
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: 'jess@example.com',
              ),
              const SizedBox(height: 30),
              const Text(
                'Preferences',
                style: TextStyle(
                  color: ZenColors.textGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.notifications_none,
                title: 'Daily reminders',
                subtitle: 'Receive gentle check-in reminders',
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: 'Soft green and ivory app styling',
              ),
              const SizedBox(height: 12),
              _buildSettingCard(
                icon: Icons.book_outlined,
                title: 'Journal mode',
                subtitle: 'View previous mood entries anytime',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ZenColors.headerGreen.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: ZenColors.headerGreen),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(value, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ZenColors.headerGreen.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: ZenColors.headerGreen),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black87)),
        trailing: const Icon(Icons.chevron_right, color: ZenColors.textGreen),
      ),
    );
  }
}
