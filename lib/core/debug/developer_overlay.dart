import 'package:flutter/material.dart';
import 'package:dopamine_budget/core/utils/time_provider.dart';

/// Глобальная debug-панель сдвига времени. Рендерится поверх любого экрана
/// через RootGate, не привязана к конкретной фиче.
class DeveloperOverlay extends StatelessWidget {
  final VoidCallback onTimeShifted;

  const DeveloperOverlay({Key? key, required this.onTimeShifted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
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
                Text(
                  'Виртуальное время: ${TimeProvider.now.toLocal().toString().substring(0, 16)}',
                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.fast_forward),
                      label: const Text('+1 День'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        TimeProvider.addDuration(const Duration(days: 1));
                        onTimeShifted();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black54,
                      ),
                      onPressed: () {
                        TimeProvider.reset();
                        onTimeShifted();
                      },
                      child: const Text('Сбросить время'),
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