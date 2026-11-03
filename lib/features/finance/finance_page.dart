import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_controller.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final strings = controller.strings;
    return Scaffold(
      key: const Key('finance-page'),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-transaction-button'),
        onPressed: () => _showTransactionForm(context),
        icon: const Icon(Icons.add),
        label: Text(strings.get('addTransaction')),
      ),
      body: controller.transactions.isEmpty
          ? Center(child: Text(strings.get('noData')))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                final row = controller.transactions[index];
                final income = row['type'] == 'income';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: income
                          ? Colors.green.withValues(alpha: .15)
                          : Colors.red.withValues(alpha: .15),
                      child: Icon(
                        income ? Icons.south_west : Icons.north_east,
                        color: income ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      (row['description'] as String? ?? '').isEmpty
                          ? (row['category'] as String? ??
                                strings.get('finance'))
                          : row['description'] as String,
                    ),
                    subtitle: Text(
                      '${row['date'] ?? ''} · ${row['category'] ?? ''}',
                    ),
                    trailing: Text(
                      '${income ? '+' : '-'}${row['amount']} ${row['currency'] ?? controller.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: income ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showTransactionForm(BuildContext context) async {
    final controller = context.read<AppController>();
    final strings = controller.strings;
    final amount = TextEditingController();
    final description = TextEditingController();
    final category = TextEditingController();
    var type = 'income';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          key: const Key('transaction-dialog'),
          title: Text(strings.get('addTransaction')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'income',
                      label: Text(strings.get('revenue')),
                    ),
                    ButtonSegment(
                      value: 'expense',
                      label: Text(strings.get('expense')),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (value) =>
                      setState(() => type = value.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('transaction-amount'),
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: strings.get('amount')),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: category,
                  decoration: InputDecoration(
                    labelText: strings.get('category'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  decoration: InputDecoration(
                    labelText: strings.get('description'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.get('cancel')),
            ),
            FilledButton(
              key: const Key('transaction-save'),
              onPressed: () async {
                final value = double.tryParse(amount.text.trim());
                if (value == null) return;
                await controller.repository.insert('transactions', {
                  'type': type,
                  'amount': value,
                  'category': category.text.trim(),
                  'description': description.text.trim(),
                  'date': DateTime.now().toIso8601String().substring(0, 10),
                  'currency': controller.currency,
                });
                await controller.refresh();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(strings.get('save')),
            ),
          ],
        ),
      ),
    );
    amount.dispose();
    description.dispose();
    category.dispose();
  }
}
