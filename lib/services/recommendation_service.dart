import '../../models/job_model.dart';
import 'job_service.dart';

class RecommendationService {
  /// Get personalized job recommendations
  static Future<List<Job>> getRecommendations({
    required List<String> favoriteJobIds,
    required List<String> appliedJobIds,
    required String userRole,
    String? userLocation,
    int maxResults = 5,
  }) async {
    // Fetch all jobs
    final allJobs = await JobService.getJobs();

    if (allJobs.isEmpty) return [];

    // Filter applied jobs
    final availableJobs = allJobs
        .where((job) => !appliedJobIds.contains(job.id))
        .toList();

    if (availableJobs.isEmpty) return [];

    // Score each job based on various factors
    final scoredJobs = availableJobs.map((job) {
      double score = 0;

      // Factor 1: Similar location (25 points)
      if (userLocation != null && job.location.toLowerCase() == userLocation.toLowerCase()) {
        score += 25;
      }

      // Factor 2: Job similarity to favorites (30 points)
      if (_isJobSimilarToFavorites(job, allJobs, favoriteJobIds)) {
        score += 30;
      }

      // Factor 3: Job trending (based on number of applications, simulated)
      if (job.applicationCount != null && job.applicationCount! > 10) {
        score += 15;
      }

      // Factor 4: Salary match (10 points) - assuming user wants higher salary
      if (job.salaryMin != null && job.salaryMin! > 30000) {
        score += 10;
      }

      // Factor 5: Recent posting (5 points)
      final daysSincePosting = DateTime.now().difference(job.createdAt).inDays;
      if (daysSincePosting < 7) {
        score += 5;
      }

      // Factor 6: Contract type preference (15 points)
      if (job.contractType.toLowerCase().contains('cdi') ||
          job.contractType.toLowerCase().contains('permanent')) {
        score += 15;
      }

      return {'job': job, 'score': score};
    }).toList();

    // Sort by score and return top results
    scoredJobs.sort((a, b) {
      final scoreA = (a['score'] as num?)?.toDouble() ?? 0;
      final scoreB = (b['score'] as num?)?.toDouble() ?? 0;
      return scoreB.compareTo(scoreA);
    });

    return scoredJobs
        .take(maxResults)
        .map((item) => item['job'] as Job)
        .toList();
  }

  /// Check if a job is similar to user's favorite jobs
  static bool _isJobSimilarToFavorites(
    Job job,
    List<Job> allJobs,
    List<String> favoriteJobIds,
  ) {
    if (favoriteJobIds.isEmpty) return false;

    final favoriteJobs = allJobs
        .where((j) => favoriteJobIds.contains(j.id))
        .toList();

    if (favoriteJobs.isEmpty) return false;

    // Check if job is in same domain/company
    for (final fav in favoriteJobs) {
      if (job.companyName == fav.companyName) return true;
      if (_calculateTextSimilarity(job.title, fav.title) > 0.6) return true;
      if (job.contractType == fav.contractType) return true;
    }

    return false;
  }

  /// Simple text similarity calculation (Levenshtein distance based)
  static double _calculateTextSimilarity(String s1, String s2) {
    final s1Lower = s1.toLowerCase();
    final s2Lower = s2.toLowerCase();

    if (s1Lower == s2Lower) return 1.0;

    final commonWords = s1Lower.split(' ').where(
      (word) => s2Lower.contains(word),
    ).length;

    return commonWords / (s1Lower.split(' ').length + 1);
  }

  /// Get jobs by category
  static Future<List<Job>> getJobsByCategory(String category) async {
    final allJobs = await JobService.getJobs();
    return allJobs
        .where((job) => job.title.toLowerCase().contains(category.toLowerCase()) ||
            job.description.toLowerCase().contains(category.toLowerCase()))
        .take(5)
        .toList();
  }

  /// Get trending jobs
  static Future<List<Job>> getTrendingJobs({int maxResults = 5}) async {
    final allJobs = await JobService.getJobs();

    final sortedJobs = allJobs.toList()
      ..sort((a, b) {
        final aCount = a.applicationCount ?? 0;
        final bCount = b.applicationCount ?? 0;
        return bCount.compareTo(aCount);
      });

    return sortedJobs.take(maxResults).toList();
  }

  /// Get jobs by salary range
  static Future<List<Job>> getJobsBySalaryRange({
    required double minSalary,
    required double maxSalary,
    int maxResults = 5,
  }) async {
    final allJobs = await JobService.getJobs();

    return allJobs
        .where((job) {
          if (job.salaryMin == null || job.salaryMax == null) return false;
          return job.salaryMin! >= minSalary && job.salaryMax! <= maxSalary;
        })
        .take(maxResults)
        .toList();
  }

  /// Get similar jobs by job id
  static Future<List<Job>> getSimilarJobs(
    String jobId, {
    int maxResults = 5,
  }) async {
    final allJobs = await JobService.getJobs();
    final targetJob = allJobs.firstWhere(
      (j) => j.id == jobId,
      orElse: () => null as dynamic,
    ) as Job?;

    if (targetJob == null) return [];

    return allJobs
        .where((job) =>
            job.id != jobId &&
            (job.companyName == targetJob.companyName ||
                job.contractType == targetJob.contractType ||
                job.location == targetJob.location))
        .take(maxResults)
        .toList();
  }
}
