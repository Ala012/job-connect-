import 'dart:convert';
import 'dart:typed_data';
import '../models/application_model.dart';
import '../models/job_model.dart';
import 'api_service.dart';
import 'job_api_service.dart' as job_api;

class ApplicationApiService {
  // Get all applications
  static Future<List<Application>> getAllApplications() async {
    final response = await ApiService.get('/applications');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => _applicationFromBackendJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  // Get applications by applicant ID
  static Future<List<Application>> getApplicationsByApplicantId(String applicantId) async {
    final response = await ApiService.get('/applications/byApplicant/$applicantId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => _applicationFromBackendJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  // Get applications by job ID
  static Future<List<Application>> getApplicationsByJobId(String jobId) async {
    final response = await ApiService.get('/applications/job/$jobId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => _applicationFromBackendJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  // Get applications by entreprise ID
  static Future<List<Application>> getApplicationsByEntrepriseId(String entrepriseId) async {
    final response = await ApiService.get('/applications/byEntreprise/$entrepriseId');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => _applicationFromBackendJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  // Apply for a job
  static Future<Application> applyForJob({
    required String jobId,
    required String userId,
    required String entrepriseId,
  }) async {
    final response = await ApiService.post('/applications', {
      'job_id': jobId,
      'user_id': userId,
      'entreprise_id': entrepriseId,
      'status': 'pending',
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return _applicationFromBackendJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to apply for job');
    }
  }

  // Upload CV for an application
  static Future<void> uploadApplicationCV({
    required String applicationId,
    required Uint8List cvBytes,
    required String cvFileName,
  }) async {
    try {
      // Create multipart request for file upload
      // This endpoint depends on your backend implementation
      // You may need to implement this on the backend side
      final response = await ApiService.postFile(
        '/applications/$applicationId/cv',
        cvBytes,
        cvFileName,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload CV');
      }
    } catch (e) {
      // Log the error but don't fail the application process
      print('Error uploading CV: $e');
      rethrow;
    }
  }

  // Convert backend application format to our Application model
  static Application _applicationFromBackendJson(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final jobId = json['job_id']?.toString() ?? json['job']?['_id']?.toString() ?? '';
    final userId = json['user_id']?.toString() ?? json['user']?['_id']?.toString() ?? '';
    
    // Backend status: 'pending', 'contract_signed', 'started', 'finished'
    // Map to our status: 'sent', 'under_review', 'accepted', 'rejected'
    String status = 'sent';
    final backendStatus = json['status'] ?? 'pending';
    switch (backendStatus) {
      case 'pending':
        status = 'sent';
        break;
      case 'contract_signed':
        status = 'accepted';
        break;
      case 'started':
      case 'finished':
        status = 'under_review';
        break;
    }

    // Get user info
    final user = json['user'] ?? {};
    final employeeName = user['name'] ?? 'Unknown';
    final employeePhoto = user['avatar'];

    // Get job info
    Job? job;
    if (json['job'] != null) {
      try {
        // Use the extension method to access the private function
        job = job_api.JobApiService.jobFromBackendJson(json['job'] as Map<String, dynamic>);
      } catch (e) {
        // If job parsing fails, continue without job
      }
    }

    return Application(
      id: id,
      jobId: jobId,
      employeeId: userId,
      employeeName: employeeName,
      employeePhoto: employeePhoto,
      cvUrl: null, // Backend doesn't have CV URL in application
      status: status,
      appliedAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      job: job,
    );
  }
}

