import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/state/app_controller.dart';
import '../dashboard/dashboard_page.dart';
import '../projects/projects_page.dart';
import '../finance/finance_page.dart';
import '../field/field_page.dart';
import '../team/team_page.dart';
import '../settings/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<int> _history = [0];
  int _section = 0;

  static const _icons = <IconData>[
    Icons.dashboard_outlined,
    Icons.folder_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.place_outlined,
    Icons.group_outlined,
    Icons.settings_outlined,
  ];

  void _selectSection(int index) {
    if (_section == index) return;
    setState(() {
      _section = index;
      if (_history.last != index) _history.add(index);
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSystemBack() async {
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState?.isDrawerOpen ?? false) {
      scaffoldState!.closeDrawer();
      return;
    }
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _section = _history.last;
      });
      return;
    }
    final controller = context.read<AppController>();
    final strings = controller.strings;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('exit-confirmation'),
        title: Text(strings.get('exitTitle')),
        content: Text(strings.get('exitBody')),
        actions: [
          TextButton(
            key: const Key('exit-cancel'),
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.get('cancel')),
          ),
          FilledButton(
            key: const Key('exit-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.get('exit')),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      // SystemNavigator closes the Android task without discarding local records.
      await SystemNavigator.pop();
    }
  }

  Future<void> _exportPdf(AppController controller) async {
    final pdf = pw.Document();
    final income = controller.transactions
        .where((row) => row['type'] == 'income')
        .fold<double>(0, (sum, row) => sum + (row['amount'] as num).toDouble());
    final expense = controller.transactions
        .where((row) => row['type'] == 'expense')
        .fold<double>(0, (sum, row) => sum + (row['amount'] as num).toDouble());
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'MAYDAN'),
          pw.Text(controller.strings.get('overview')),
          pw.SizedBox(height: 12),
          pw.Text(
            '${controller.strings.get('income')}: $income ${controller.currency}',
          ),
          pw.Text(
            '${controller.strings.get('expenses')}: $expense ${controller.currency}',
          ),
          pw.Text(
            '${controller.strings.get('profit')}: ${income - expense} ${controller.currency}',
          ),
          pw.SizedBox(height: 20),
          pw.Text(controller.strings.get('projects')),
          ...controller.projects.map(
            (project) => pw.Bullet(
              text: '${project['name']} - ${project['progress'] ?? 0}%',
            ),
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'maydan-report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final strings = controller.strings;
    final labels = [
      strings.get('dashboard'),
      strings.get('projects'),
      strings.get('finance'),
      strings.get('field'),
      strings.get('team'),
      strings.get('settings'),
    ];
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_handleSystemBack());
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: isWide
            ? null
            : Drawer(
                child: SafeArea(
                  child: ListView(
                    children: [
                      const DrawerHeader(
                        child: Text(
                          'ميدان · MAYDAN',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      for (var i = 0; i < labels.length; i++)
                        ListTile(
                          key: Key('drawer-section-$i'),
                          leading: Icon(_icons[i]),
                          selected: _section == i,
                          title: Text(labels[i]),
                          onTap: () => _selectSection(i),
                        ),
                    ],
                  ),
                ),
              ),
        appBar: AppBar(
          title: Text(labels[_section], key: const Key('app-shell-title')),
          actions: [
            IconButton(
              key: const Key('export-pdf'),
              tooltip: 'PDF',
              onPressed: () => _exportPdf(controller),
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
            IconButton(
              key: const Key('refresh-data'),
              tooltip: strings.get('actions'),
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _section,
            children: const [
              DashboardPage(),
              ProjectsPage(),
              FinancePage(),
              FieldPage(),
              TeamPage(),
              SettingsPage(),
            ],
          ),
        ),
        bottomNavigationBar: isWide
            ? null
            : NavigationBar(
                selectedIndex: _section,
                onDestinationSelected: _selectSection,
                destinations: [
                  for (var i = 0; i < 5; i++)
                    NavigationDestination(
                      key: Key('nav-section-$i'),
                      icon: Icon(_icons[i]),
                      label: labels[i],
                    ),
                ],
              ),
      ),
    );
  }
}
