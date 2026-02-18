import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/app_theme.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _domainController = TextEditingController();
  final _sizeController = TextEditingController();
  String? _logoPath;
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
      _logoPath = user.profilePhoto;
      // Load additional company info from user.additionalInfo if available
      if (user.additionalInfo != null) {
        _addressController.text = user.additionalInfo!['address'] ?? '';
        _descriptionController.text = user.additionalInfo!['description'] ?? '';
        _domainController.text = user.additionalInfo!['domain'] ?? '';
        _sizeController.text = user.additionalInfo!['size'] ?? '';
      }
    }
  }

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    // In a real app, you would update the company profile with new data
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
    _addressController.dispose();
    _descriptionController.dispose();
    _domainController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil entreprise'),
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
                  backgroundImage: _logoPath != null
                      ? (_logoPath!.startsWith('http')
                          ? NetworkImage(_logoPath!) as ImageProvider
                          : FileImage(File(_logoPath!)) as ImageProvider)
                      : null,
                  child: _logoPath == null
                      ? Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : 'C',
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
                      onPressed: _pickLogo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'entreprise',
                prefixIcon: Icon(Icons.business),
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
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _domainController,
              decoration: const InputDecoration(
                labelText: 'Domaine d\'activité',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sizeController,
              decoration: const InputDecoration(
                labelText: 'Taille de l\'entreprise',
                prefixIcon: Icon(Icons.people),
                hintText: 'Ex: 10-50, 50-200, etc.',
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
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
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
                        leading: const Icon(Icons.person_add),
                        title: const Text('Nouvelles candidatures'),
                        trailing: Switch(
                          value: notificationsProvider
                              .newApplicationsNotifications,
                          onChanged: (value) {
                            notificationsProvider
                                .toggleNewApplicationsNotifications(value);
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

