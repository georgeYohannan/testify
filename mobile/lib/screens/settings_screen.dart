import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Profile'),
              subtitle: const Text('Manage your account settings'),
              onTap: () {
                // TODO: Navigate to profile settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile settings coming soon!')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.orange),
              title: const Text('Notifications'),
              subtitle: const Text('Configure quiz reminders'),
              onTap: () {
                // TODO: Navigate to notification settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification settings coming soon!')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.color_lens, color: Colors.purple),
              title: const Text('Appearance'),
              subtitle: const Text('Customize the app theme'),
              onTap: () {
                // TODO: Navigate to appearance settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appearance settings coming soon!')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.green),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help and contact support'),
              onTap: () {
                // TODO: Navigate to help section
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help section coming soon!')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('About'),
              subtitle: const Text('App version and information'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Testify',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.quiz, size: 48),
                  children: const [
                    Text('A joyful Bible quiz app with an animated elephant mascot.'),
                    SizedBox(height: 16),
                    Text('Test your knowledge of the Bible with interactive quizzes based on different books.'),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/auth');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
