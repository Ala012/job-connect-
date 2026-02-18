import 'dart:convert';
import '../models/job_model.dart';
import 'api_service.dart';


class JobApiService {
  // Get all jobs
  static Future<List<Job>> getAllJobs() async {
    final response = await ApiService.get('/job');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => jobFromBackendJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  // Get job by ID
  static Future<Job?> getJobById(String jobId) async {
    final response = await ApiService.get('/job/$jobId');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return jobFromBackendJson(data);
    } else {
      return null;
    }
  }

  // Get jobs by user ID (company jobs)
  static Future<List<Job>> getJobsByUserId(String userId) async {
    final response = await ApiService.get(
      '/job/by-user',
      queryParams: {'userID': userId},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => jobFromBackendJson(json)).toList();
    } else {
      throw Exception('Failed to load company jobs');
    }
  }

  // Get jobs by city
  static Future<List<Job>> getJobsByCity(String city) async {
    final response = await ApiService.get(
      '/job/byCity',
      queryParams: {'city': city},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => jobFromBackendJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs by city');
    }
  }

  // Create job
  static Future<Job> createJob(Map<String, dynamic> jobData) async {
    final response = await ApiService.post('/job/create', jobData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return jobFromBackendJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create job');
    }
  }

  // Convert backend job format to our Job model
  static Job jobFromBackendJson(Map<String, dynamic> json) {
    // Backend structure: title, description, address, price, pricing_type, contract, startDate, endDate, entreprise_id
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final entrepriseId = json['entreprise_id']?.toString() ?? '';
    
    // Parse dates
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString());
    }
    createdAt ??= DateTime.now();

    DateTime? endDate;
    if (json['endDate'] != null) {
      endDate = DateTime.tryParse(json['endDate'].toString());
    }

    // Map backend fields to our model
    return Job(
      id: id,
      companyId: entrepriseId,
      companyName: json['entreprise']?['name'] ?? 'Unknown Company',
      companyLogo: json['entreprise']?['avatar'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requiredSkills: [], // Backend doesn't have skills field, would need to be added
      contractType: json['contract'] ?? 'full-time',
      experienceLevel: 'mid', // Backend doesn't have this, defaulting
      location: json['address'] ?? '',
      salaryMin: json['price']?.toDouble(),
      salaryMax: json['price']?.toDouble(), // Backend has single price
      createdAt: createdAt,
      deadline: endDate,
      isActive: endDate == null || endDate.isAfter(DateTime.now()),
      applicationCount: json['applicants_ids']?.length ?? 0,
    );
  }
}

