import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';
import '../services/dashboard_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../state/application_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService service = DashboardService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruckIQ Dashboard'),
        actions: [
          Consumer<ApplicationState>(
            builder: (context, appState, _) {
              return IconButton(
                icon: Icon(
                  appState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  appState.toggleTheme();
                },
                tooltip: appState.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, 'alerts');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            StreamBuilder<int>(
              stream: service.getDriverCount(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const DashboardCard(title: "Drivers", value: "0");
                }
                return DashboardCard(
                  title: "Drivers",
                  value: snapshot.data.toString(),
                );
              },
            ),
            StreamBuilder<int>(
              stream: service.getTruckCount(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const DashboardCard(title: "Trucks", value: "0");
                }
                return DashboardCard(
                  title: "Trucks",
                  value: snapshot.data.toString(),
                );
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => FirebaseAuth.instance.signOut(),
        child: const Icon(Icons.logout),
      ),
    );
  }
}
