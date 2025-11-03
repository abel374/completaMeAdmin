import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            children: const [
              ListTile(title: Text('Project / Firebase')),
              ListTile(title: Text('User management settings')),
              ListTile(title: Text('Rider settings')),
            ],
          ),
        ),
      ],
    );
  }
}
