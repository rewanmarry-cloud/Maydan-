import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_strings.dart';
import '../../core/state/app_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final strings = controller.strings;
    final income = controller.transactions
        .where((row) => row['type'] == 'income')
        .fold<double>(0, (sum, row) => sum + (row['amount'] as num).toDouble());
    final expense = controller.transactions
        .where((row) => row['type'] == 'expense')
        .fold<double>(0, (sum, row) => sum + (row['amount'] as num).toDouble());
    final budget = controller.projects.fold<double>(
      0,
      (sum, row) => sum + ((row['budget'] as num?)?.toDouble() ?? 0),
    );
    return ListView(
      key: const Key('dashboard-page'),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          strings.get('overview'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
              children: [
                _MetricCard(
                  strings.get('income'),
                  _money(income, controller.currency),
                  Icons.trending_up,
                ),
                _MetricCard(
                  strings.get('expenses'),
                  _money(expense, controller.currency),
                  Icons.trending_down,
                ),
                _MetricCard(
                  strings.get('profit'),
                  _money(income - expense, controller.currency),
                  Icons.savings_outlined,
                ),
                _MetricCard(
                  strings.get('projectBudget'),
                  _money(budget, controller.currency),
                  Icons.account_balance_outlined,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.get('projects'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (controller.projects.isEmpty)
                  Text(strings.get('noData'))
                else
                  ...controller.projects
                      .take(5)
                      .map(
                        (project) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(child: Text(project['name'] as String)),
                              SizedBox(
                                width: 120,
                                child: LinearProgressIndicator(
                                  value:
                                      ((project['progress'] as int? ?? 0) / 100)
                                          .toDouble()
                                          .clamp(0.0, 1.0),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(westernDigits(project['progress'] ?? 0)),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _money(double amount, String currency) =>
      '${westernDigits(amount.toStringAsFixed(2))} $currency';
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.title, this.value, this.icon);
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            FittedBox(
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
