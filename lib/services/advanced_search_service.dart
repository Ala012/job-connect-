import '../../models/job_model.dart';
import 'job_service.dart';

class AdvancedSearchService {
  /// Effectue une recherche avancée avec tous les critères
  static Future<List<Job>> advancedSearch({
    String? searchQuery,
    String? contractType,
    String? experienceLevel,
    String? location,
    double? minSalary,
    double? maxSalary,
    List<String>? skills,
    bool? isRemote,
  }) async {
    // Récupère tous les emplois avec les filtres de base
    final jobs = await JobService.getJobs(
      contractType: contractType,
      experienceLevel: experienceLevel,
      location: location,
      minSalary: minSalary,
    );

    // Filtre par critères avancés
    return jobs.where((job) {
      // Filtre par recherche textuelle
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!job.title.toLowerCase().contains(query) &&
            !job.description.toLowerCase().contains(query) &&
            !job.companyName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtre par salaire maximum
      if (maxSalary != null && job.salaryMax != null) {
        if (job.salaryMax! > maxSalary) return false;
      }

      // Filtre par compétences requises
      if (skills != null && skills.isNotEmpty) {
        final jobSkills = job.requiredSkills;
        final hasAllSkills = skills.every((skill) =>
            jobSkills.any((js) =>
                js.toLowerCase().contains(skill.toLowerCase())));
        if (!hasAllSkills) return false;
      }

      return true;
    }).toList();
  }

  /// Recherche par titre et description
  static Future<List<Job>> searchByKeyword(String keyword) async {
    final allJobs = await JobService.getJobs();
    final query = keyword.toLowerCase();

    return allJobs
        .where((job) =>
            job.title.toLowerCase().contains(query) ||
            job.description.toLowerCase().contains(query) ||
            job.companyName.toLowerCase().contains(query) ||
            (job.requiredSkills.any((skill) =>
                    skill.toLowerCase().contains(query))))
        .toList();
  }

  /// Recherche par compétences
  static Future<List<Job>> searchBySkills(List<String> skills) async {
    final allJobs = await JobService.getJobs();

    return allJobs
        .where((job) {
          final jobSkills = job.requiredSkills;
          return skills.any((skill) => jobSkills
              .any((js) => js.toLowerCase().contains(skill.toLowerCase())));
        })
        .toList();
  }

  /// Obtient les statistiques de recherche
  static Future<Map<String, dynamic>> getSearchStats() async {
    final allJobs = await JobService.getJobs();

    return {
      'totalJobs': allJobs.length,
      'contractTypes': _groupBy(allJobs, (job) => job.contractType).length,
      'locations': _groupBy(allJobs, (job) => job.location).length,
      'companies': _groupBy(allJobs, (job) => job.companyName).length,
      'avgSalary': _calculateAvgSalary(allJobs),
    };
  }

  static Map<String, List<T>> _groupBy<T, K>(
      List<T> items, K Function(T) keyFn) {
    final map = <String, List<T>>{};
    for (final item in items) {
      final key = keyFn(item).toString();
      (map[key] ??= []).add(item);
    }
    return map;
  }

  static double _calculateAvgSalary(List<Job> jobs) {
    final salaries = jobs
        .where((job) =>
            job.salaryMin != null &&
            job.salaryMin! > 0 &&
            job.salaryMax != null &&
            job.salaryMax! > 0)
        .map((job) => ((job.salaryMin ?? 0) + (job.salaryMax ?? 0)) / 2)
        .toList();

    if (salaries.isEmpty) return 0;
    return salaries.reduce((a, b) => a + b) / salaries.length;
  }
}
