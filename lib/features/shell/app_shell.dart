// lib/app_shell.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/auth/auth_repository.dart';
import '../pages/home_page.dart';
import '../pages/drugs_page.dart';
import '../drugs/add_drug_page.dart';
import '../pages/stock_page.dart';
import '../pages/logs_page.dart';

class AppShell extends StatefulWidget {
  final AuthRepository auth;
  const AppShell({super.key, required this.auth});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _pages = const [
    HomePage(),
    DrugsPage(),
    SizedBox.shrink(),
    StockPage(),
    LogsPage(),
  ];

  Future<void> _openAddDrug() async {
    final result = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => const AddDrugPage()),
    );

    if (result != true || !mounted) return;

    setState(() => _index = 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('บันทึกยาเรียบร้อย'),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: cs.error),
              const SizedBox(width: 10),
              const Text('ออกจากระบบ'),
            ],
          ),
          content: const Text('คุณแน่ใจหรือไม่ที่จะออกจากระบบ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ออก'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      await widget.auth.signOut();
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true, // ✅ ให้ bottom nav ลอยบนพื้นหลังได้สวย
      appBar: AppBar(
        title: Text(
          'PharmaStock',
          style: GoogleFonts.sarabun(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'ออกจากระบบ',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],

        // ✅ สีเดียวแต่ไม่แข็ง: base สี primary + highlight จาง ๆ
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: cs.primary),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.7, -0.9),
                  radius: 1.4,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.75],
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: _pages[_index],
          ),
        ),
      ),

      // ✅ NavigationBar แบบลอย pill + shadow
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.10),
              ),
            ],
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: NavigationBar(
              height: 72,
              selectedIndex: _index,
              onDestinationSelected: (i) {
                if (i == 2) {
                  _openAddDrug();
                  return;
                }
                setState(() => _index = i);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medication_rounded),
                  label: 'Drugs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_box_rounded),
                  label: 'Add',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_rounded),
                  label: 'Stock',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'Logs',
                ),
              ],
            ),
          ),
        ),
      ),

      // NOTE: คุณตั้ง centerDocked ไว้แล้ว ถึงจะไม่ใช้ FAB ก็ไม่เป็นไร
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}