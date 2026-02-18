import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../providers/favorites_provider.dart';
import '../../services/job_service.dart';
import '../../utils/app_theme.dart';
import 'job_detail_screen.dart';
import 'job_filters_sheet.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<Job> _allJobs = [];
  List<Job> _jobs = [];
  bool _isLoading = true;
  bool _isGridView = false;
  String? _selectedContractType;
  String? _selectedExperience;
  String? _selectedLocation;
  double? _minSalary;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _searchController.addListener(_filterJobs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
    });

    final jobs = await JobService.getJobs(
      contractType: _selectedContractType,
      experienceLevel: _selectedExperience,
      location: _selectedLocation,
      minSalary: _minSalary,
    );

    setState(() {
      _allJobs = jobs;
      _filterJobs();
      _isLoading = false;
    });
  }

  void _filterJobs() {
    setState(() {
      _jobs = _allJobs.where((job) {
        final query = _searchQuery.toLowerCase();
        return job.title.toLowerCase().contains(query) ||
            job.description.toLowerCase().contains(query) ||
            job.companyName.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _showFilters() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => JobFiltersSheet(
        contractType: _selectedContractType,
        experience: _selectedExperience,
        location: _selectedLocation,
        minSalary: _minSalary,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedContractType = result['contractType'];
        _selectedExperience = result['experience'];
        _selectedLocation = result['location'];
        _minSalary = result['minSalary'];
      });
      _loadJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres d\'emploi'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un emploi, une compétence...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _filterJobs();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _filterJobs();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _jobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Aucune offre trouvée'
                                  : 'Aucune offre disponible',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _jobs.length,
                            itemBuilder: (context, index) => _JobCard(job: _jobs[index]),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _jobs.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _JobCard(job: _jobs[index], isList: true),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final bool isList;

  const _JobCard({required this.job, this.isList = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
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
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: job.companyLogo != null
                        ? ClipOval(child: Image.network(job.companyLogo!, fit: BoxFit.cover))
                        : Text(
                            job.companyName[0].toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          job.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: isList ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(label: job.contractType, icon: Icons.access_time),
                  _Chip(label: job.experienceLevel, icon: Icons.trending_up),
                  _Chip(label: job.location, icon: Icons.location_on),
                ],
              ),
              if (job.salaryMin != null || job.salaryMax != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${job.salaryMin != null ? '${job.salaryMin!.toStringAsFixed(0)}€' : ''}${job.salaryMin != null && job.salaryMax != null ? ' - ' : ''}${job.salaryMax != null ? '${job.salaryMax!.toStringAsFixed(0)}€' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}


