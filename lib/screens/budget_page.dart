import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pontebarbon/providers/user_provider.dart';
import 'package:pontebarbon/models/expense_model.dart';
import 'package:pontebarbon/services/expense_service.dart';
import 'package:pontebarbon/services/ml_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final TextEditingController _budgetController = TextEditingController();
  List<dynamic> _expenses = [];
  bool _loadingExpenses = false;
  Map<String, dynamic>? _mlInsights;
  bool _loadingML = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() { _loadingExpenses = true; });
    final service = ExpenseService();
    try {
      final expenses = await service.fetchExpenses(4); // Usuario demo 4
      setState(() {
        _expenses = expenses;
      });
    } catch (e) {
      // Puedes mostrar un error si lo deseas
    } finally {
      setState(() { _loadingExpenses = false; });
    }
  }

  Future<void> _loadMLInsights() async {
    setState(() { _loadingML = true; });
    final service = MLService();
    try {
      final insights = await service.fetchDashboardInsights();
      setState(() {
        _mlInsights = insights;
      });
    } catch (e) {
      setState(() {
        _mlInsights = {'error': 'No se pudo obtener insights'};
      });
    } finally {
      setState(() { _loadingML = false; });
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

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
          _buildExpensesList(), // Agrega la lista de gastos
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
    final userProvider = Provider.of<UserProvider>(context);
    final totalExpenses = userProvider.totalExpenses;
    final remainingBudget = userProvider.remainingBudget;

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
              _buildSummaryCard(cardWidth, 'Amount Spent', '\$${totalExpenses.toStringAsFixed(2)}'),
              const SizedBox(width: 8),
              _buildSummaryCard(cardWidth, 'Remaining', '\$${remainingBudget.toStringAsFixed(2)}'),
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
              final items = [
                {'title': 'Add Expense', 'icon': Icons.add_circle_outline, 'color': Colors.red},
                {'title': 'View History', 'icon': Icons.history, 'color': Colors.blue},
                {'title': 'Set Budget', 'icon': Icons.account_balance_wallet, 'color': Colors.green},
                {'title': 'Analytics', 'icon': Icons.pie_chart, 'color': Colors.purple},
              ];

              return _buildQuickLinkCard(
                context,
                items[index]['title'] as String,
                items[index]['icon'] as IconData,
                items[index]['color'] as Color,
                onTap: () {
                  if (index == 0) {
                    _showAddExpenseDialog(context);
                  } else if (index == 1) {
                    _showExpenseHistoryDialog(context);
                  } else if (index == 2) {
                    _showSetBudgetDialog(context);
                  } else if (index == 3) {
                    _showAnalyticsDialog(context);
                  }
                },
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuickLinkCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color, {
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddExpenseDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showSetBudgetDialog(context),
          icon: const Icon(Icons.edit),
          label: const Text('Update Budget'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Acción para Machine Learning
            _showMachineLearningDialog(context);
          },
          icon: const Icon(Icons.auto_graph),
          label: const Text('Machine Learning'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _showMachineLearningDialog(BuildContext context) {
    _loadMLInsights();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Machine Learning Insights'),
        content: SizedBox(
          width: double.maxFinite,
          child: _loadingML
              ? const Center(child: CircularProgressIndicator())
              : _mlInsights == null
                  ? const Text('No hay datos de ML.')
                  : SingleChildScrollView(child: _buildMLInsightsContent(_mlInsights!)),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMLInsightsContent(Map<String, dynamic> data) {
    if (data.containsKey('error')) {
      return Text(data['error']);
    }
    final summary = data['summary'] ?? {};
    final clusters = data['cluster_distribution'] ?? [];
    final categories = data['top_categories'] ?? [];
    final quickInsights = data['quick_insights'] ?? [];
    final savings = data['savings_opportunities'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Total gastos: S/. ${summary['total_expenses']}'),
        Text('Promedio mensual: S/. ${summary['avg_monthly']}'),
        Text('Transacciones: ${summary['transaction_count']}'),
        Text('Tipo más usado: ${summary['most_used_type']}'),
        Text('Score financiero: ${summary['financial_health_score']}'),
        const SizedBox(height: 12),
        Text('Clusters:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...clusters.map<Widget>((c) => Card(
          color: Color(int.parse(c['color'].substring(1, 7), radix: 16) + 0xFF000000),
          child: ListTile(
            leading: Text(c['icon'], style: TextStyle(fontSize: 24)),
            title: Text(c['cluster_name']),
            subtitle: Text(c['description']),
            trailing: Text('Promedio: S/. ${c['avg_amount']}'),
          ),
        )),
        const SizedBox(height: 12),
        Text('Top categorías:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...categories.map<Widget>((cat) => ListTile(
          title: Text(cat['category']),
          subtitle: Text('Total: S/. ${cat['total_amount']} | Promedio: S/. ${cat['avg_amount']}'),
          trailing: Text('${cat['percentage']}%'),
        )),
        const SizedBox(height: 12),
        Text('Quick Insights:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...quickInsights.map<Widget>((qi) => Text(qi)),
        const SizedBox(height: 12),
        Text('Oportunidades de ahorro:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...savings.map<Widget>((s) => ListTile(
          title: Text(s['category']),
          subtitle: Text('Actual: S/. ${s['current_amount']} | Potencial ahorro: S/. ${s['potential_savings']}'),
          trailing: Text(s['recommendation']),
        )),
      ],
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != selectedDate) {
                    // Handle date change
                    selectedDate = picked;
                    // Need setState if this was in a StatefulWidget
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate inputs
              if (descriptionController.text.isEmpty || amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              // Parse amount
              final amount = double.tryParse(amountController.text);
              if (amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              // Create expense object
              final expense = ExpenseModel(
                description: descriptionController.text,
                amount: amount,
                date: selectedDate,
              );

              // TODO: Save expense to database or provider

              // Close dialog
              Navigator.pop(context);

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense added successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExpenseHistoryDialog(BuildContext context) {
    // This would typically fetch expenses from a database or provider
    final List<ExpenseModel> expenses = [
      // Example data
      ExpenseModel(
        description: 'Groceries',
        amount: 45.99,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ExpenseModel(
        description: 'Dinner',
        amount: 32.50,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expense History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                title: Text(expense.description),
                subtitle: Text(
                  '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                ),
                trailing: Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _budgetController.text = userProvider.monthlyBudget.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: _budgetController,
          decoration: const InputDecoration(
            labelText: 'Monthly Budget (\$)',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final budgetText = _budgetController.text.trim();
              if (budgetText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a budget amount')),
                );
                return;
              }

              final budget = double.tryParse(budgetText);
              if (budget == null || budget < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid budget amount')),
                );
                return;
              }

              // Update budget in provider
              userProvider.updateMonthlyBudget(budget);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expense Analytics'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Analytics feature coming soon!',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_loadingExpenses) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_expenses.isEmpty) {
      return const Text('No hay gastos registrados.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gastos registrados:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _expenses.length,
          itemBuilder: (context, index) {
            final expense = _expenses[index];
            return Card(
              child: ListTile(
                title: Text(expense['description'] ?? ''),
                subtitle: Text('Monto: ${expense['amount']} | Fecha: ${expense['dateOfExpense'] ?? ''}'),
                trailing: Text(expense['type']?.toString() ?? ''),
              ),
            );
          },
        ),
      ],
    );
  }
}