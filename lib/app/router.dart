import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/device/device_screen.dart';
import '../features/map/map_screen.dart';
import '../features/permission/permission_screen.dart';
import '../features/satellites/satellites_screen.dart';
import '../features/skyplot/skyplot_screen.dart';
import '../state/providers.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/satellites',
            builder: (context, state) => const SatellitesScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/sky',
            builder: (context, state) => const SkyplotScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/device',
            builder: (context, state) => const DeviceScreen(),
          ),
        ]),
      ],
    ),
  ],
);

class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = ref.watch(locationPermissionProvider);

    if (!hasPermission) {
      return const PermissionScreen();
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _NavBar(navigationShell: navigationShell),
    );
  }
}

class _NavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _NavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: l10n.navDashboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.satellite_alt_outlined),
          selectedIcon: const Icon(Icons.satellite_alt),
          label: l10n.navSatellites,
        ),
        NavigationDestination(
          icon: const Icon(Icons.radar_outlined),
          selectedIcon: const Icon(Icons.radar),
          label: l10n.navSky,
        ),
        NavigationDestination(
          icon: const Icon(Icons.map_outlined),
          selectedIcon: const Icon(Icons.map),
          label: l10n.navMap,
        ),
        NavigationDestination(
          icon: const Icon(Icons.developer_board_outlined),
          selectedIcon: const Icon(Icons.developer_board),
          label: l10n.navDevice,
        ),
      ],
    );
  }
}
