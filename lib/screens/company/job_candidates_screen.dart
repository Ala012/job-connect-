import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../services/job_service.dart';
import '../../utils/app_theme.dart';
import 'candidate_detail_screen.dart';

class JobCandidatesScreen extends StatefulWidget {
  final Job job;

  const JobCandidatesScreen({super.key, required this.job});

  @override
  State<JobCandidatesScreen> createState() => _JobCandidatesScreenState();
}

class _JobCandidatesScreenState extends State<JobCandidatesScreen> {
  List<Application> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
    });

    final applications = await JobService.getJobApplications(widget.job.id);
    setState(() {
      _applications = applications;
      _isLoading = false;
    });
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

  Future<void> _updateStatus(String applicationId, String newStatus) async {
    await JobService.updateApplicationStatus(applicationId, newStatus);
    _loadCandidates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidats - ${widget.job.title}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun candidat pour cette offre',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCandidates,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _applications.length,
                    itemBuilder: (context, index) {
                      final application = _applications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CandidateDetailScreen(application: application),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
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
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            application.employeeName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
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
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (application.cvUrl != null) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.description, size: 16, color: AppTheme.primaryColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        'CV disponible',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (application.status == 'sent' || application.status == 'under_review') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _updateStatus(application.id, 'accepted'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.green,
                                          ),
                                          child: const Text('Accepter'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _updateStatus(application.id, 'rejected'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
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
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

