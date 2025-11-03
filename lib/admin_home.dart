import 'package:flutter/material.dart';
import 'package:foodpanda_admin_web_portal/screens/dashboard_screen.dart';
import 'package:foodpanda_admin_web_portal/screens/orders_screen.dart';
import 'package:foodpanda_admin_web_portal/screens/users_screen.dart';
import 'package:foodpanda_admin_web_portal/screens/sellers_screen.dart';
import 'package:foodpanda_admin_web_portal/screens/sliders_screen.dart';

import 'screens/riders_screen.dart';
import 'screens/settings_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    SlidersScreen(),
    UsersScreen(),
    RidersScreen(),
    SellersScreen(),
    OrdersScreen(),
    SettingsScreen(),
  ];

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.photo_library),
      label: Text('Sliders'),
    ),
    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Users')),
    NavigationRailDestination(
      icon: Icon(Icons.pedal_bike),
      label: Text('Riders'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.storefront),
      label: Text('Sellers'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long),
      label: Text('Orders'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings),
      label: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodpanda Admin Portal'),
        centerTitle: false,
      ),
      drawer: wide
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(child: Text('Admin Menu')),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    selected: _selectedIndex == 0,
                    onTap: () => setState(() {
                      _selectedIndex = 0;
                      Navigator.of(context).pop();
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Sliders'),
                    selected: _selectedIndex == 1,
                    onTap: () => setState(() {
                      _selectedIndex = 1;
                      Navigator.of(context).pop();
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Users'),
                    selected: _selectedIndex == 2,
                    onTap: () => setState(() {
                      _selectedIndex = 2;
                      Navigator.of(context).pop();
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pedal_bike),
                    title: const Text('Riders'),
                    selected: _selectedIndex == 3,
                    onTap: () => setState(() {
                      _selectedIndex = 3;
                      Navigator.of(context).pop();
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront),
                    title: const Text('Sellers'),
                    selected: _selectedIndex == 4,
                    onTap: () => setState(() {
                      _selectedIndex = 4;
                      Navigator.of(context).pop();
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Orders'),
                    selected: _selectedIndex == 5,
                    onTap: () => setState(() {
                      _selectedIndex = 5;
                      Navigator.of(context).pop();
                    }),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    selected: _selectedIndex == 6,
                    onTap: () => setState(() {
                      _selectedIndex = 6;
                      Navigator.of(context).pop();
                    }),
                  ),
                ],
              ),
            ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: _destinations,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
