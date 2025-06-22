import 'package:flutter/material.dart';
import 'package:pontebarbon/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:pontebarbon/providers/registration_provider.dart';
import 'package:pontebarbon/screens/registration/step4_complete.dart';
import 'package:pontebarbon/services/database_helper.dart';
import 'package:pontebarbon/widgets/step_indicator.dart';
import 'package:intl/intl.dart';

class ReviewInfoScreen extends StatelessWidget {
  const ReviewInfoScreen({super.key});

  Future<void> _completeRegistration(BuildContext context, UserModel user) async {
    final databaseHelper = DatabaseHelper();

    try {
      // Insert user into database
      final result = await databaseHelper.insertUser(user.toMap());

      if (result == -1) {
        // User already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A user with this email already exists'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Registration successful, navigate to complete screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileCompleteScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final user = registrationProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Info'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Final Step: Review Your Info',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Personal Information
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  'Full Name',
                  user.fullName ?? '',
                  Icons.person,
                ),
                _buildInfoTile(
                  'Email',
                  user.email ?? '',
                  Icons.email,
                ),
                _buildInfoTile(
                  'Date of Birth',
                  user.dateOfBirth != null
                      ? DateFormat('MMM dd, yyyy').format(user.dateOfBirth!)
                      : '',
                  Icons.calendar_today,
                ),
                _buildInfoTile(
                  'Gender',
                  user.gender ?? '',
                  Icons.people,
                ),

                const SizedBox(height: 32),

                // Financial Overview
                const Text(
                  'Financial Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  'Currently Saving',
                  user.isSaving == true ? 'Yes' : 'No',
                  Icons.savings,
                ),
                _buildInfoTile(
                  'Income Range',
                  user.incomeRange ?? '',
                  Icons.attach_money,
                ),
                _buildInfoTile(
                  'Financial Goals',
                  user.financialGoals?.join(', ') ?? '',
                  Icons.trending_up,
                ),

                const SizedBox(height: 32),

                // Confirm and Finish Button
                ElevatedButton(
                  onPressed: () => _completeRegistration(context, user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirm and Finish'),
                ),

                const SizedBox(height: 24),

                // Step indicator
                const StepIndicator(currentStep: 3, totalSteps: 3),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Step 3 of 3',
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

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
