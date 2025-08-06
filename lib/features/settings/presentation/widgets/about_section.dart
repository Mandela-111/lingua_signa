import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'About LinguaSigna',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // App Info
            _InfoRow(
              label: 'Version',
              value: '1.0.0',
              icon: Icons.app_registration,
            ),
            
            const SizedBox(height: 8),
            
            _InfoRow(
              label: 'Build',
              value: '2024.1.15',
              icon: Icons.build,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'LinguaSigna is a mobile sign language recognition app that provides real-time translation for American Sign Language (ASL) and Ghanaian Sign Language (GSL) with integrated video conferencing capabilities.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showPrivacyPolicy(context),
                  icon: const Icon(Icons.privacy_tip, size: 16),
                  label: const Text('Privacy Policy'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showTermsOfService(context),
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text('Terms of Service'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Support
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Get Support'),
              subtitle: const Text('Contact us for help and feedback'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSupportOptions(context),
              contentPadding: EdgeInsets.zero,
            ),
            
            // Feedback
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Send Feedback'),
              subtitle: const Text('Help us improve LinguaSigna'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showFeedbackForm(context),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    )
        .animate(delay: 400.ms)
        .slideX(begin: -0.2, end: 0)
        .fadeIn(duration: 400.ms);
  }
  
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'LinguaSigna is committed to protecting your privacy. We collect minimal data necessary for app functionality and never share personal information with third parties.\n\n'
            'Camera and microphone access is used only for real-time translation and video calling features. No video or audio data is stored on our servers.\n\n'
            'Translation history is stored locally on your device and can be cleared at any time in settings.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using LinguaSigna, you agree to these terms:\n\n'
            '1. The app is provided for educational and communication purposes\n'
            '2. Translation accuracy may vary and should not be relied upon for critical communications\n'
            '3. Users are responsible for their own safety during video calls\n'
            '4. We reserve the right to update these terms as needed\n\n'
            'For complete terms, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Get Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('support@linguasigna.com'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help Center'),
              subtitle: const Text('Browse frequently asked questions'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: const Text('Community Forum'),
              subtitle: const Text('Connect with other users'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFeedbackForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                hintText: 'Brief description of your feedback',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'Tell us what you think...',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback sent! Thank you.')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}