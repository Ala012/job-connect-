import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/job_service.dart';
import '../../utils/app_theme.dart';

class PublishJobScreen extends StatefulWidget {
  const PublishJobScreen({super.key});

  @override
  State<PublishJobScreen> createState() => _PublishJobScreenState();
}

class _PublishJobScreenState extends State<PublishJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _deadlineController = TextEditingController();

  String _contractType = 'full-time';
  String _experienceLevel = 'mid';
  List<String> _requiredSkills = [];
  final _skillController = TextEditingController();
  DateTime? _deadline;
  bool _isSubmitting = false;

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _deadline = date;
        _deadlineController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _requiredSkills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _requiredSkills.remove(skill);
    });
  }

  Future<void> _publishJob() async {
    if (!_formKey.currentState!.validate()) return;

    if (_requiredSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une compétence requise')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    final job = Job(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyId: user.id,
      companyName: user.name,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      requiredSkills: _requiredSkills,
      contractType: _contractType,
      experienceLevel: _experienceLevel,
      location: _locationController.text.trim(),
      salaryMin: _salaryMinController.text.trim().isEmpty
          ? null
          : double.tryParse(_salaryMinController.text.trim()),
      salaryMax: _salaryMaxController.text.trim().isEmpty
          ? null
          : double.tryParse(_salaryMaxController.text.trim()),
      createdAt: DateTime.now(),
      deadline: _deadline,
      isActive: true,
    );

    try {
      await JobService.createJob(job);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre publiée avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _deadlineController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier une offre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du poste *',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localisation *',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une localisation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Type de contrat *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['full-time', 'part-time', 'contract', 'internship'].map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _contractType == type,
                    onSelected: (selected) {
                      setState(() {
                        _contractType = type;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Niveau d\'expérience *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['junior', 'mid', 'senior'].map((exp) {
                  return ChoiceChip(
                    label: Text(exp),
                    selected: _experienceLevel == exp,
                    onSelected: (selected) {
                      setState(() {
                        _experienceLevel = exp;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Salaire min (€)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Salaire max (€)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date limite',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _selectDeadline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Compétences requises *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      decoration: const InputDecoration(
                        labelText: 'Ajouter une compétence',
                        hintText: 'Ex: Flutter, React, etc.',
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addSkill,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _requiredSkills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    onDeleted: () => _removeSkill(skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _publishJob,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publier l\'offre'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


