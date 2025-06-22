import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pontebarbon/providers/registration_provider.dart';
import 'package:pontebarbon/screens/registration/step3_review.dart';
import 'package:pontebarbon/widgets/step_indicator.dart';

class FinancialPreferencesScreen extends StatefulWidget {
  const FinancialPreferencesScreen({super.key});

  @override
  _FinancialPreferencesScreenState createState() => _FinancialPreferencesScreenState();
}

class _FinancialPreferencesScreenState extends State<FinancialPreferencesScreen> {
  bool _isSaving = false;
  String _selectedIncomeRange = '';
  final List<String> _selectedGoals = [];

  final List<String> _incomeRanges = [
    '\$0–500',
    '\$500–1,000',
    '\$1,000–1,500',
    '\$1,500+',
  ];

  final List<String> _financialGoals = [
    'Saving for emergencies',
    'Paying off debt',
    'Investing',
    'Budgeting better',
  ];

  void _continueToNextStep() {
    if (_selectedIncomeRange.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your income range')),
      );
      return;
    }

    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one financial goal')),
      );
      return;
    }

    // Save financial preferences to the provider
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    provider.updateFinancialPreferences(
      isSaving: _isSaving,
      incomeRange: _selectedIncomeRange,
      financialGoals: _selectedGoals,
    );

    // Navigate to review screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReviewInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Preferences'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Do you currently save money?
                const Text(
                  'Do you currently save money?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Yes/No toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSaving = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isSaving
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade200,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                color: _isSaving ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSaving = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isSaving
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade200,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'No',
                              style: TextStyle(
                                color: !_isSaving ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Income range
                const Text(
                  'What is your monthly income range?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Income range radio buttons
                ...List.generate(_incomeRanges.length, (index) {
                  final incomeRange = _incomeRanges[index];
                  return RadioListTile<String>(
                    title: Text(incomeRange),
                    value: incomeRange,
                    groupValue: _selectedIncomeRange,
                    onChanged: (value) {
                      setState(() {
                        _selectedIncomeRange = value!;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  );
                }),

                const SizedBox(height: 32),

                // Financial goals
                const Text(
                  'What financial goal are you most focused on?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select all that apply',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Financial goals checkboxes
                ...List.generate(_financialGoals.length, (index) {
                  final goal = _financialGoals[index];
                  return CheckboxListTile(
                    title: Text(goal),
                    value: _selectedGoals.contains(goal),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedGoals.add(goal);
                        } else {
                          _selectedGoals.remove(goal);
                        }
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  );
                }),

                const SizedBox(height: 32),

                // Continue Button
                ElevatedButton(
                  onPressed: _continueToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue'),
                ),

                const SizedBox(height: 24),

                // Step indicator
                const StepIndicator(currentStep: 2, totalSteps: 3),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Step 2 of 3',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
