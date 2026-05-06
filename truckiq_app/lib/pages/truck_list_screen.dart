import 'package:flutter/material.dart';
import 'package:truckiq_app/services/truck_service.dart';
import '../models/truck.dart';
import 'package:intl/intl.dart';

class TruckListScreen extends StatelessWidget {
  const TruckListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TruckService();

    return Scaffold(
      appBar: AppBar(title: const Text('Trucks')),
      body: StreamBuilder<List<Truck>>(
        stream: service.getTrucks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trucks found'));
          }

          final trucks = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: const [
                    SizedBox(
                      width: 60,
                      child: Text(
                        "Truck Number",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: Text(
                          "Last service Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 80,
                      child: Text(
                        "Action",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: trucks.length,
                  itemBuilder: (context, index) {
                    final truck = trucks[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Center(child: Text(truck.truckNumber)),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                truck.latestServiceDate != null
                                    ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(truck.latestServiceDate!)
                                    : 'N/A',
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 130,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      'truck-detail',
                                      arguments:
                                          truck.id,
                                    );
                                  },
                                  child: const Text("View"),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Truck'),
                                        content: Text(
                                          'Are you sure you want to delete ${truck.truckNumber}? This action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      await service.deleteTruck(truck.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'edit-truck');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
