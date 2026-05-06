import 'package:flutter_test/flutter_test.dart';
import 'package:truckiq_app/models/driver.dart';

void main() {
  test('Driver object stores values correctly', () {
    final driver = Driver(
      id: '1',
      name: 'John',
      licenseNumber: 'ABC123',
      tickets: 2,
      incidents: 1,
      onShift: true,
      assignedTruck: 'Truck 1',
      hiredOn: DateTime(2024, 1, 1),
    );

    expect(driver.name, 'John');
    expect(driver.tickets, 2);
    expect(driver.incidents, 1);
    expect(driver.assignedTruck, 'Truck 1');
    expect(driver.licenseNumber, 'ABC123');
    expect(driver.onShift, true);
    expect(driver.hiredOn, DateTime(2024, 1, 1));
  });
}
