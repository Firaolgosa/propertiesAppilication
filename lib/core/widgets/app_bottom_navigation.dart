import 'package:flutter/material.dart';
import 'package:properties/features/home/presentation/view/manager_tenant.dart';
import 'package:properties/features/home/presentation/view/owner_home.dart';
import 'package:properties/features/home/presentation/view/tenant_home.dart';
import 'package:properties/features/properties/presentation/view/manager_properties.dart';
import 'package:properties/features/properties/presentation/view/owner_properties.dart';
import 'package:properties/features/properties/presentation/view/tenant_properties.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userType;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleNavigation(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: _getNavigationItems(),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    // Common items for all user types
    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
    ];

    // Add user-specific second tab
    if (userType == 'Tenant') {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.apartment),
        label: 'My Unit',
      ));
    } else {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.apartment),
        label: 'Properties',
      ));
    }

    // Add user-specific items
    if (userType == 'Tenant') {
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Payments',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: 'Maintenance',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ]);
    } else {
      // For Manager and Owner
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Finances',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: 'Maintenance',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ]);
    }

    return items;
  }

  void _handleNavigation(BuildContext context, int index) {
    // Call the onTap callback to update the state in the parent widget
    onTap(index);

    // If we're already on the selected tab, don't navigate
    if (index == currentIndex) return;

    // Navigate to the appropriate screen based on the selected index and user type
    Widget? destinationScreen;

    switch (index) {
      case 0: // Home tab
        if (userType == 'Tenant') {
          destinationScreen = const TenantHomeScreen();
        } else if (userType == 'Owner') {
          destinationScreen = const OwnerHomeScreen();
        } else if (userType == 'Manager') {
          destinationScreen = const ManagerTenantScreen();
        }
        break;
      case 1: // Properties tab
        if (userType == 'Owner') {
          destinationScreen = const OwnerPropertiesScreen();
        } else if (userType == 'Tenant') {
          destinationScreen = const TenantPropertiesScreen();
        } else {
          destinationScreen = const ManagerPropertiesScreen();
        }
        break;
      case 2: // Payments or Finances tab
        if (userType == 'Tenant') {
          // Payments for Tenant
          // Add the appropriate screen when available
        } else {
          // Finances for Manager and Owner
          // Add the appropriate screen when available
        }
        break;
      case 3: // Maintenance tab
        if (userType == 'Tenant' || userType == 'Manager' || userType == 'Owner') {
          // Maintenance screen
          // Add the appropriate screen when available
        }
        break;
      case 4: // Messages tab
        if (userType == 'Tenant' || userType == 'Manager' || userType == 'Owner') {
          // Messages screen
          // Add the appropriate screen when available
        }
        break;
    }

    if (destinationScreen != null) {
      // Use pushReplacement instead of push to replace the current screen
      // This prevents screens from stacking on top of each other
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destinationScreen!),
      );
    }
  }
}

