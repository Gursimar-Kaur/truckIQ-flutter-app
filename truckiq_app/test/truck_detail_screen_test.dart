import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

String computePredictedNextService(DateTime? latestServiceDate) {
  if (latestServiceDate == null) return 'N/A';
  final next = DateTime(
    latestServiceDate.year,
    latestServiceDate.month + 6,
    latestServiceDate.day,
  );
  return DateFormat('yyyy-MM-dd').format(next);
}

double computeMonthlyMaintenanceCost(
  List<Map<String, dynamic>> records,
  DateTime now,
) {
  double total = 0.0;
  for (final record in records) {
    final date = record['date'] as DateTime?;
    final cost = record['cost'] as num?;
    if (date != null && cost != null) {
      if (date.year == now.year && date.month == now.month) {
        total += cost.toDouble();
      }
    }
  }
  return total;
}

void main() {
  group('TruckDetailScreen - predicted next service date', () {
    test('returns N/A when latestServiceDate is null', () {
      expect(computePredictedNextService(null), 'N/A');
    });

    test('adds 6 months to the last service date', () {
      final input = DateTime(2024, 1, 15);
      expect(computePredictedNextService(input), '2024-07-15');
    });
  });

  group('TruckDetailScreen - monthly maintenance cost', () {
    final now = DateTime(2024, 6, 15);

    test('returns 0 when no records exist', () {
      expect(computeMonthlyMaintenanceCost([], now), 0.0);
    });

    test('sums only records from the current month', () {
      final records = [
        {'date': DateTime(2024, 6, 5), 'cost': 150.0},
        {'date': DateTime(2024, 6, 20), 'cost': 75.50},
        {'date': DateTime(2024, 5, 10), 'cost': 999.0}, // previous month
      ];
      expect(computeMonthlyMaintenanceCost(records, now), 225.50);
    });

    test('ignores records with null date or cost', () {
      final records = [
        {'date': null, 'cost': 100.0},
        {'date': DateTime(2024, 6, 1), 'cost': null},
        {'date': DateTime(2024, 6, 1), 'cost': 50.0},
      ];
      expect(computeMonthlyMaintenanceCost(records, now), 50.0);
    });

    test('returns 0 when all records are from different months', () {
      final records = [  
        {'date': DateTime(2024, 3, 1), 'cost': 200.0},
        {'date': DateTime(2024, 4, 1), 'cost': 300.0},
      ];
      expect(computeMonthlyMaintenanceCost(records, now), 0.0);
    });
  });
}