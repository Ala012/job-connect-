import 'dart:typed_data';
import '../models/job_model.dart';
import '../models/application_model.dart';
import 'job_api_service.dart';
import 'application_api_service.dart';

class JobService {
  static Future<List<Job>> getJobs({
    String? contractType,
    String? experienceLevel,
    String? location,
    double? minSalary,
  }) async {
    try {
      List<Job> allJobs;
      
      // If location filter is provided, use backend filter
      if (location != null && location.isNotEmpty) {
        allJobs = await JobApiService.getJobsByCity(location);
      } else {
        allJobs = await JobApiService.getAllJobs();
      }
      
      // Apply client-side filters
      var filteredJobs = allJobs;
      
      if (contractType != null && contractType.isNotEmpty) {
        filteredJobs = filteredJobs.where((j) => j.contractType == contractType).toList();
      }
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        filteredJobs = filteredJobs.where((j) => j.experienceLevel == experienceLevel).toList();
      }
      if (minSalary != null) {
        filteredJobs = filteredJobs.where((j) => j.salaryMin != null && j.salaryMin! >= minSalary).toList();
      }
      
      return filteredJobs;
    } catch (e) {
      // Fallback to empty list on error
      return [];
    }
  }

  static Future<Job?> getJobById(String jobId) async {
    try {
      return await JobApiService.getJobById(jobId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Job>> getCompanyJobs(String companyId) async {
    try {
      return await JobApiService.getJobsByUserId(companyId);
    } catch (e) {
      return [];
    }
  }

  static Future<Job> createJob(Job job) async {
    // Convert Job to backend format
    final jobData = {
      'title': job.title,
      'description': job.description,
      'address': job.location,
      'price': job.salaryMin ?? 0,
      'pricing_type': 'per hour',
      'contract': job.contractType,
      'startDate': job.createdAt.toIso8601String(),
      'endDate': job.deadline?.toIso8601String() ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'work_hours': 8,
      'duration': '1 month',
      'startTime': '09:00',
      'endTime': '17:00',
    };
    
    return await JobApiService.createJob(jobData);
  }

  static Future<Application> applyToJob(
    String jobId,
    String employeeId,
    String employeeName,
    Uint8List? cvBytes,
    String? cvFileName,
  ) async {
    // Get job to find entreprise_id
    final job = await getJobById(jobId);
    if (job == null) {
      throw Exception('Job not found');
    }

    // Apply for job and upload CV if provided
    final application = await ApplicationApiService.applyForJob(
      jobId: jobId,
      userId: employeeId,
      entrepriseId: job.companyId,
    );

    // Upload CV if bytes are available
    if (cvBytes != null && cvFileName != null) {
      try {
        await ApplicationApiService.uploadApplicationCV(
          applicationId: application.id,
          cvBytes: cvBytes,
          cvFileName: cvFileName,
        );
      } catch (e) {
        // Log but don't fail - application was already created
        print('Error uploading CV: $e');
      }
    }

    return application;
  }

  static Future<List<Application>> getEmployeeApplications(String employeeId) async {
    try {
      return await ApplicationApiService.getApplicationsByApplicantId(employeeId);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Application>> getJobApplications(String jobId) async {
    try {
      return await ApplicationApiService.getApplicationsByJobId(jobId);
    } catch (e) {
      return [];
    }
  }

  static Future<void> updateApplicationStatus(String applicationId, String status) async {
    // Backend doesn't have an update status endpoint in the controller
    // This would need to be added to the backend or handled differently
    // For now, we'll just log it
    // TODO: Add update status endpoint to backend or implement workaround
  }
}


