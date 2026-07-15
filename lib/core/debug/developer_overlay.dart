import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

/// Глобальная debug-панель сдвига времени. Рендерится поверх любого экрана
/// через RootGate, не привязана к конкретной фиче.
class DeveloperOverlay extends StatelessWidget {
  Future<void> _exportDb(BuildContext context) async {
    try {
      const src = '/data/data/com.example.dopamine_budget/app_flutter/db.sqlite';
      final dst = '/data/data/com.example.dopamine_budget/cache/dopamine_export.db';
      await File(src).copy(dst);
      await Share.shareXFiles([XFile(dst)], text: 'dopamine.db');
    } catch (e) {
      debugPrint('DB ERROR: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), duration: const Duration(seconds: 5)),
        );
      }
    }
  }
  final VoidCallback onTimeShifted;

  const DeveloperOverlay({Key? key, required this.onTimeShifted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: Card(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Text(
                //  'Виртуальное время: ${TimeProvider.now.toLocal().toString().substring(0, 16)}',
                //  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
               // ),
                //const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.fast_forward),
                      label: const Text('+1Д'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      ),
                      onPressed: () {
                        TimeProvider.addDuration(const Duration(days: 1));
                        onTimeShifted();
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.schedule),
                      label: const Text('+4ч'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade400,
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      ),
                      onPressed: () {
                        TimeProvider.addDuration(const Duration(hours: 4));
                        onTimeShifted();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black54,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      ),
                      onPressed: () {
                        TimeProvider.reset();
                        onTimeShifted();
                      },
                      child: const Text('Сброс'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      ),
                      onPressed: () => _exportDb(context),
                      child: const Text('DB→SD'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}