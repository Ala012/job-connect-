class Job {
  final String id;
  final String companyId;
  final String companyName;
  final String? companyLogo;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String contractType; // 'full-time', 'part-time', 'contract', 'internship'
  final String experienceLevel; // 'junior', 'mid', 'senior'
  final String location;
  final double? salaryMin;
  final double? salaryMax;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isActive;
  final int? applicationCount;

  Job({
    required this.id,
    required this.companyId,
    required this.companyName,
    this.companyLogo,
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.contractType,
    required this.experienceLevel,
    required this.location,
    this.salaryMin,
    this.salaryMax,
    required this.createdAt,
    this.deadline,
    this.isActive = true,
    this.applicationCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      companyName: json['companyName'] ?? '',
      companyLogo: json['companyLogo'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      contractType: json['contractType'] ?? 'full-time',
      experienceLevel: json['experienceLevel'] ?? 'mid',
      location: json['location'] ?? '',
      salaryMin: json['salaryMin']?.toDouble(),
      salaryMax: json['salaryMax']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isActive: json['isActive'] ?? true,
      applicationCount: json['applicationCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'title': title,
      'description': description,
      'requiredSkills': requiredSkills,
      'contractType': contractType,
      'experienceLevel': experienceLevel,
      'location': location,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'isActive': isActive,
      'applicationCount': applicationCount,
    };
  }
}


