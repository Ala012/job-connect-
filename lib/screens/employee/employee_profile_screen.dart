import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/app_theme.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  String? _profilePhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _profilePhoto = user.profilePhoto;
    }
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePhoto = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    // In a real app, you would update the user with new data and upload the photo
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil mis à jour avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: _profilePhoto != null
                      ? (_profilePhoto!.startsWith('http')
                          ? NetworkImage(_profilePhoto!) as ImageProvider
                          : FileImage(File(_profilePhoto!)) as ImageProvider)
                      : null,
                  child: _profilePhoto == null
                      ? Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 48,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return TextField(
                  controller: TextEditingController(text: authProvider.currentUser?.email ?? ''),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  enabled: false,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Biographie',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Enregistrer'),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.work_history),
              title: const Text('Expériences professionnelles'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to experience management
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Compétences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to skills management
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Mon CV'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to CV management
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_4),
              title: const Text('Mode sombre'),
              trailing: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.setDarkMode(value);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Consumer<NotificationsProvider>(
              builder: (context, notificationsProvider, _) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications globales'),
                      trailing: Switch(
                        value: notificationsProvider.notificationsEnabled,
                        onChanged: (value) {
                          notificationsProvider.toggleNotifications(value);
                        },
                      ),
                    ),
                    if (notificationsProvider.notificationsEnabled) ...[
                      ListTile(
                        leading: const Icon(Icons.check_circle),
                        title: const Text('Statut des candidatures'),
                        trailing: Switch(
                          value: notificationsProvider
                              .applicationStatusNotifications,
                          onChanged: (value) {
                            notificationsProvider
                                .toggleApplicationStatusNotifications(value);
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.work),
                        title: const Text('Nouvelles offres'),
                        trailing: Switch(
                          value: notificationsProvider.newJobNotifications,
                          onChanged: (value) {
                            notificationsProvider
                                .toggleNewJobNotifications(value);
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.alarm),
                        title: const Text('Rappels'),
                        trailing: Switch(
                          value: notificationsProvider.reminderNotifications,
                          onChanged: (value) {
                            notificationsProvider
                                .toggleReminderNotifications(value);
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Langue / Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Consumer<LocalizationProvider>(
              builder: (context, localizationProvider, _) {
                return ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Langue'),
                  trailing: DropdownButton<String>(
                    value: localizationProvider.currentLocale.languageCode,
                    items: const [
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        localizationProvider.setLocale(Locale(value));
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

