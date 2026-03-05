import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/safety_monitoring_screen.dart';
import 'services/helmet_service.dart';
import 'services/navigation_service.dart';
import 'services/emergency_service.dart';

void main() {
  runApp(const SmartHelmetApp());
}

class SmartHelmetApp extends StatelessWidget {
  const SmartHelmetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HelmetService>(create: (_) => HelmetService()),
        Provider<NavigationService>(create: (_) => NavigationService()),
        Provider<EmergencyService>(create: (_) => EmergencyService()),
      ],
      child: MaterialApp(
        title: 'Smart Helmet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
        home: const MainNavigationWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NavigationScreen(),
    const SafetyMonitoringScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Navigation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Safety',
          ),
        ],
      ),
    );
  }
}