import 'job_model.dart';

class Application {
  final String id;
  final String jobId;
  final String employeeId;
  final String employeeName;
  final String? employeePhoto;
  final String? cvUrl;
  final String status; // 'sent', 'under_review', 'accepted', 'rejected'
  final DateTime appliedAt;
  final Job? job;

  Application({
    required this.id,
    required this.jobId,
    required this.employeeId,
    required this.employeeName,
    this.employeePhoto,
    this.cvUrl,
    required this.status,
    required this.appliedAt,
    this.job,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      employeePhoto: json['employeePhoto'],
      cvUrl: json['cvUrl'],
      status: json['status'] ?? 'sent',
      appliedAt: DateTime.parse(json['appliedAt'] ?? DateTime.now().toIso8601String()),
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeePhoto': employeePhoto,
      'cvUrl': cvUrl,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }
}


