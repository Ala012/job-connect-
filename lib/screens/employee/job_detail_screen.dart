import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/app_theme.dart';
import 'apply_job_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'offre'),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, _) {
              return IconButton(
                icon: Icon(
                  favoritesProvider.isFavorite(job.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favoritesProvider.isFavorite(job.id)
                      ? Colors.red
                      : Colors.grey,
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(job.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        favoritesProvider.isFavorite(job.id)
                            ? 'Ajouté aux favoris'
                            : 'Retiré des favoris',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: job.companyLogo != null
                        ? ClipOval(child: Image.network(job.companyLogo!, fit: BoxFit.cover))
                        : Text(
                            job.companyName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.companyName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(icon: Icons.location_on, label: 'Localisation', value: job.location),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.access_time, label: 'Type de contrat', value: job.contractType),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.trending_up, label: 'Expérience', value: job.experienceLevel),
                  if (job.salaryMin != null || job.salaryMax != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.attach_money,
                      label: 'Salaire',
                      value: '${job.salaryMin != null ? '${job.salaryMin!.toStringAsFixed(0)}€' : ''}${job.salaryMin != null && job.salaryMax != null ? ' - ' : ''}${job.salaryMax != null ? '${job.salaryMax!.toStringAsFixed(0)}€' : ''}',
                    ),
                  ],
                  if (job.deadline != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Date limite',
                      value: '${job.deadline!.day}/${job.deadline!.month}/${job.deadline!.year}',
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Compétences requises',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.requiredSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplyJobScreen(job: job),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Postuler maintenant'),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}


