import 'package:flutter/material.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          _buildHeaderTitle(context),
          const SizedBox(height: 24),

          // Savings Summary Section
          _buildSavingsSummarySection(context),
          const SizedBox(height: 32),

          // Quick Links Section
          _buildQuickLinksSection(context),
          const SizedBox(height: 32),

          // Bottom Buttons
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

  Widget _buildSavingsSummarySection(BuildContext context) {
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
        LayoutBuilder(
            builder: (context, constraints) {
              // Calculate card width based on available space
              final cardWidth = (constraints.maxWidth - 16) / 3;
              return Row(
                children: [
                  // Total Budget Card
                  _buildSummaryCard(cardWidth, 'Total Budget', '\$0'),
                  const SizedBox(width: 8),

                  // Amount Spent Card
                  _buildSummaryCard(cardWidth, 'Amount Spent', '\$0'),
                  const SizedBox(width: 8),

                  // Remaining Balance Card
                  _buildSummaryCard(cardWidth, 'Remaining', '\$0'),
                ],
              );
            }
        ),
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
        LayoutBuilder(
            builder: (context, constraints) {
              // Make grid responsive based on screen width
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  // Dynamically calculate height based on content
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
                      );
                    case 1:
                      return _buildQuickLinkCard(
                        context,
                        'Savings Goals',
                        'Set new savings targets.',
                        Icons.savings,
                        Colors.green,
                      );
                    case 2:
                      return _buildQuickLinkCard(
                        context,
                        'Recent Expenses',
                        'Check where your money went.',
                        Icons.receipt_long,
                        Colors.orange,
                      );
                    case 3:
                      return _buildQuickLinkCard(
                        context,
                        'Financial Goals',
                        'See how close you are to your targets.',
                        Icons.insert_chart,
                        Colors.purple,
                      );
                    default:
                      return const SizedBox();
                  }
                },
              );
            }
        ),
      ],
    );
  }

  Widget _buildQuickLinkCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color iconColor,
      ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Functionality will be added later
        },
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

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // View Report Button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Functionality will be added later
            },
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

        // Add Expense Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Functionality will be added later
            },
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