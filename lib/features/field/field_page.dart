import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_controller.dart';

class FieldPage extends StatelessWidget {
  const FieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final strings = controller.strings;
    return Scaffold(
      key: const Key('field-page'),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-visit-button'),
        onPressed: () => _showVisitForm(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(strings.get('addVisit')),
      ),
      body: controller.visits.isEmpty
          ? Center(child: Text(strings.get('noData')))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: controller.visits.length,
              itemBuilder: (context, index) {
                final visit = controller.visits[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.place_outlined),
                    ),
                    title: Text(
                      visit['notes'] as String? ?? strings.get('addVisit'),
                    ),
                    subtitle: Text(
                      '${visit['date'] ?? ''} · ${visit['responsible'] ?? ''}',
                    ),
                    trailing: Text('${visit['progress'] ?? 0}%'),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showVisitForm(BuildContext context) async {
    final controller = context.read<AppController>();
    final strings = controller.strings;
    final responsible = TextEditingController();
    final notes = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('visit-dialog'),
        title: Text(strings.get('addVisit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: responsible,
              decoration: InputDecoration(labelText: strings.get('role')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: strings.get('description'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.get('cancel')),
          ),
          FilledButton(
            key: const Key('visit-save'),
            onPressed: () async {
              await controller.repository.insert('visits', {
                'responsible': responsible.text.trim(),
                'notes': notes.text.trim(),
                'date': DateTime.now().toIso8601String().substring(0, 10),
                'progress': 0,
              });
              await controller.refresh();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: Text(strings.get('save')),
          ),
        ],
      ),
    );
    responsible.dispose();
    notes.dispose();
  }
}
