import 'package:flutter/material.dart';

class JobFiltersSheet extends StatefulWidget {
  final String? contractType;
  final String? experience;
  final String? location;
  final double? minSalary;

  const JobFiltersSheet({
    super.key,
    this.contractType,
    this.experience,
    this.location,
    this.minSalary,
  });

  @override
  State<JobFiltersSheet> createState() => _JobFiltersSheetState();
}

class _JobFiltersSheetState extends State<JobFiltersSheet> {
  String? _selectedContractType;
  String? _selectedExperience;
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedContractType = widget.contractType;
    _selectedExperience = widget.experience;
    _locationController.text = widget.location ?? '';
    _salaryController.text = widget.minSalary?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'contractType': _selectedContractType,
      'experience': _selectedExperience,
      'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      'minSalary': _salaryController.text.trim().isEmpty ? null : double.tryParse(_salaryController.text.trim()),
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedContractType = null;
      _selectedExperience = null;
      _locationController.clear();
      _salaryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Type de contrat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['full-time', 'part-time', 'contract', 'internship'].map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _selectedContractType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedContractType = selected ? type : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Niveau d\'expérience',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['junior', 'mid', 'senior'].map((exp) {
              return ChoiceChip(
                label: Text(exp),
                selected: _selectedExperience == exp,
                onSelected: (selected) {
                  setState(() {
                    _selectedExperience = selected ? exp : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Localisation',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Salaire minimum (€)',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Appliquer les filtres'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}


