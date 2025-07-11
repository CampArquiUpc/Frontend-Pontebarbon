import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pontebarbon/providers/user_provider.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final monthlyBudget = userProvider.monthlyBudget;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderTitle(context),
          const SizedBox(height: 24),
          _buildSavingsSummarySection(context, monthlyBudget),
          const SizedBox(height: 32),
          _buildQuickLinksSection(context),
          const SizedBox(height: 32),
          _buildBottomButtons(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle(BuildContext context) {
    return const Text(
      "Let's manage your finances",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSavingsSummarySection(BuildContext context, double monthlyBudget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 16) / 3;
          return Row(
            children: [
              _buildSummaryCard(cardWidth, 'Total Budget', '\$${monthlyBudget.toStringAsFixed(2)}'),
              const SizedBox(width: 8),
              _buildSummaryCard(cardWidth, 'Amount Spent', '\$0'),
              const SizedBox(width: 8),
              _buildSummaryCard(cardWidth, 'Remaining', '\$${monthlyBudget.toStringAsFixed(2)}'),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSummaryCard(double width, String title, String amount) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: constraints.maxWidth / (2 * 140),
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildQuickLinkCard(
                    context,
                    'Edit Monthly Budget',
                    'Tap to modify your budget.',
                    Icons.edit,
                    Colors.blue,
                        () => _showBudgetDialog(context),
                  );
                case 1:
                  return _buildQuickLinkCard(
                    context,
                    'Savings Goals',
                    'Set new savings targets.',
                    Icons.savings,
                    Colors.green,
                        () {},
                  );
                case 2:
                  return _buildQuickLinkCard(
                    context,
                    'Recent Expenses',
                    'Check where your money went.',
                    Icons.receipt_long,
                    Colors.orange,
                        () {},
                  );
                case 3:
                  return _buildQuickLinkCard(
                    context,
                    'Financial Goals',
                    'See how close you are to your targets.',
                    Icons.insert_chart,
                    Colors.purple,
                        () {},
                  );
                default:
                  return const SizedBox();
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuickLinkCard(BuildContext context, String title, String subtitle,
      IconData icon, Color iconColor, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final TextEditingController budgetController = TextEditingController();
    budgetController.text = userProvider.monthlyBudget.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Monthly Budget'),
          content: TextField(
            controller: budgetController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: 'Budget Amount',
              prefixText: '\$',
              border: OutlineInputBorder(),
              hintText: 'Enter your monthly budget',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = budgetController.text.trim();
                if (value.isEmpty) return;
                try {
                  final double budget = double.parse(value);
                  if (budget >= 0) {
                    userProvider.updateMonthlyBudget(budget);
                    Navigator.of(context).pop();
                  } else {
                    _showErrorSnackBar(context, 'Budget must be positive');
                  }
                } catch (_) {
                  _showErrorSnackBar(context, 'Invalid input');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Report',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add Expense',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
