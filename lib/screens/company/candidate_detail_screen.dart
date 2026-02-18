import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../services/job_service.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class CandidateDetailScreen extends StatelessWidget {
  final Application application;

  const CandidateDetailScreen({super.key, required this.application});

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    await JobService.updateApplicationStatus(application.id, newStatus);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut mis à jour: ${newStatus == 'accepted' ? 'Accepté' : 'Refusé'}'),
          backgroundColor: newStatus == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil candidat'),
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
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    backgroundImage: application.employeePhoto != null
                        ? (application.employeePhoto!.startsWith('http')
                            ? NetworkImage(application.employeePhoto!) as ImageProvider
                            : FileImage(File(application.employeePhoto!)) as ImageProvider)
                        : null,
                    child: application.employeePhoto == null
                        ? Text(
                            application.employeeName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    application.employeeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (application.job != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Candidat pour: ${application.job!.title}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Statut de la candidature',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(application.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusLabel(application.status),
                                  style: TextStyle(
                                    color: _getStatusColor(application.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Postulé le ${DateFormat('dd/MM/yyyy à HH:mm').format(application.appliedAt)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (application.cvUrl != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.description, color: AppTheme.primaryColor),
                        title: const Text('CV'),
                        subtitle: Text(application.cvUrl!.split('/').last),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            // Download CV functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Téléchargement du CV...')),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Informations de contact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // In a real app, you would fetch employee details from the backend
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: const Text('candidat@example.com'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Téléphone'),
                    subtitle: const Text('+33 6 12 34 56 78'),
                  ),
                  if (application.status == 'sent' || application.status == 'under_review') ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(context, 'accepted'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Accepter'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(context, 'rejected'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Refuser'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'sent':
        return 'Envoyée';
      case 'under_review':
        return 'En cours d\'étude';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Refusée';
      default:
        return status;
    }
  }
}

