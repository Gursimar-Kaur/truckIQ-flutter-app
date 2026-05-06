import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:truckiq_app/models/truck.dart';
import 'package:truckiq_app/pages/alert_screen.dart';
import 'package:truckiq_app/pages/driver_list_screen.dart';
import 'package:truckiq_app/pages/driver_profile_screen.dart';
import 'package:truckiq_app/pages/edit_truck_screen.dart';
import 'package:truckiq_app/pages/truck_detail_screen.dart';
import 'package:truckiq_app/pages/truck_list_screen.dart';
import 'state/application_state.dart';
import 'pages/dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:truckiq_app/models/driver.dart';
import 'package:truckiq_app/pages/edit_driver_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      child: const MainApp(),
    ),
  );
}

final lightTheme = ThemeData.light();

final darkTheme = ThemeData.dark();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationState>(
      builder: (context, appState, _) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: appState.loggedIn
              ? const DashboardScreen()
              : SignInScreen(providers: [EmailAuthProvider()]),
          onGenerateRoute: (settings) {
            late Widget page;
            switch (settings.name) {
              case 'alerts':
                page = AlertScreen();
              case 'trucks':
                page = TruckListScreen();
              case 'drivers':
                page = DriverListScreen();
              case 'truck-detail':
                final truckId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => TruckDetailScreen(truckId: truckId),
                );
              case 'driver-detail':
                final driverId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => DriverProfileScreen(driverId: driverId),
                );
              case 'edit-driver':
                final driver = settings.arguments as Driver?;
                return MaterialPageRoute(
                  builder: (_) => EditDriverScreen(driver: driver),
                );
              case 'edit-truck':
                final truck = settings.arguments as Truck?;
                return MaterialPageRoute(
                  builder: (_) => EditTruckScreen(truck: truck),
                );
              default:
                throw Exception('Unknown Route Used');
            }
            return MaterialPageRoute(builder: (context) => page);
          },
        );
      },
    );
  }
}
