import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/app_controller.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final strings = controller.strings;
    return Scaffold(
      key: const Key('team-page'),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-employee-button'),
        onPressed: () => _showEmployeeForm(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(strings.get('addEmployee')),
      ),
      body: controller.employees.isEmpty
          ? Center(child: Text(strings.get('noData')))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: controller.employees.length,
              itemBuilder: (context, index) {
                final employee = controller.employees[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        (employee['name'] as String).isEmpty
                            ? '?'
                            : (employee['name'] as String)[0].toUpperCase(),
                      ),
                    ),
                    title: Text(employee['name'] as String),
                    subtitle: Text(employee['role'] as String? ?? ''),
                    trailing: Text(employee['email'] as String? ?? ''),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showEmployeeForm(BuildContext context) async {
    final controller = context.read<AppController>();
    final strings = controller.strings;
    final name = TextEditingController();
    final email = TextEditingController();
    var role = 'Employee';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          key: const Key('employee-dialog'),
          title: Text(strings.get('addEmployee')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: strings.get('name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: InputDecoration(labelText: strings.get('role')),
                items:
                    const [
                          'Administrator',
                          'Accountant',
                          'Supervisor',
                          'Employee',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => role = value ?? role),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.get('cancel')),
            ),
            FilledButton(
              key: const Key('employee-save'),
              onPressed: () async {
                if (name.text.trim().isEmpty) return;
                await controller.repository.insert('employees', {
                  'name': name.text.trim(),
                  'email': email.text.trim(),
                  'role': role,
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
    name.dispose();
    email.dispose();
  }
}
