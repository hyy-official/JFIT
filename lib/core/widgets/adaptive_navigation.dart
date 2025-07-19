import 'package:flutter/material.dart';
import '../utils/breakpoint_utils.dart';

/// Navigation item data structure
class AdaptiveNavigationItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String route;
  final Widget? badge;
  final VoidCallback? onTap;
  
  const AdaptiveNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    required this.route,
    this.badge,
    this.onTap,
  });
}

/// A navigation widget that adapts to different screen sizes
class AdaptiveNavigation extends StatelessWidget {
  final List<AdaptiveNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showLabels;
  
  const AdaptiveNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        switch (deviceType) {
          case DeviceType.mobile:
            return _buildBottomNavigation(context);
          case DeviceType.tablet:
            return _buildNavigationRail(context, extended: false);
          case DeviceType.desktop:
            return _buildNavigationRail(context, extended: true);
        }
      },
    );
  }
  
  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      items: items.map((item) => BottomNavigationBarItem(
        icon: Stack(
          children: [
            Icon(item.icon),
            if (item.badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: item.badge!,
              ),
          ],
        ),
        activeIcon: Stack(
          children: [
            Icon(item.selectedIcon ?? item.icon),
            if (item.badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: item.badge!,
              ),
          ],
        ),
        label: showLabels ? item.label : null,
      )).toList(),
      currentIndex: currentIndex,
      onTap: onDestinationSelected,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      type: items.length > 3 
          ? BottomNavigationBarType.shifting 
          : BottomNavigationBarType.fixed,
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
    );
  }
  
  Widget _buildNavigationRail(BuildContext context, {required bool extended}) {
    return NavigationRail(
      extended: extended,
      destinations: items.map((item) => NavigationRailDestination(
        icon: Stack(
          children: [
            Icon(item.icon),
            if (item.badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: item.badge!,
              ),
          ],
        ),
        selectedIcon: Stack(
          children: [
            Icon(item.selectedIcon ?? item.icon),
            if (item.badge != null)
              Positioned(
                right: 0,
                top: 0,
                child: item.badge!,
              ),
          ],
        ),
        label: Text(item.label),
      )).toList(),
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      leading: leading,
      trailing: trailing,
      backgroundColor: backgroundColor,
      selectedIconTheme: selectedItemColor != null 
          ? IconThemeData(color: selectedItemColor)
          : null,
      unselectedIconTheme: unselectedItemColor != null 
          ? IconThemeData(color: unselectedItemColor)
          : null,
      selectedLabelTextStyle: selectedItemColor != null 
          ? TextStyle(color: selectedItemColor)
          : null,
      unselectedLabelTextStyle: unselectedItemColor != null 
          ? TextStyle(color: unselectedItemColor)
          : null,
      labelType: extended 
          ? NavigationRailLabelType.none 
          : (showLabels ? NavigationRailLabelType.all : NavigationRailLabelType.none),
    );
  }
}

/// A scaffold that provides adaptive navigation
class AdaptiveNavigationScaffold extends StatelessWidget {
  final List<AdaptiveNavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  
  const AdaptiveNavigationScaffold({
    super.key,
    required this.navigationItems,
    required this.currentIndex,
    required this.body,
    this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        if (deviceType == DeviceType.mobile) {
          return _buildMobileScaffold(context);
        } else {
          return _buildDesktopScaffold(context, deviceType);
        }
      },
    );
  }
  
  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: AdaptiveNavigation(
        items: navigationItems,
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
  
  Widget _buildDesktopScaffold(BuildContext context, DeviceType deviceType) {
    final navigationRail = AdaptiveNavigation(
      items: navigationItems,
      currentIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
    );
    
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          navigationRail,
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// A drawer that adapts to different screen sizes
class AdaptiveDrawer extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  
  const AdaptiveDrawer({
    super.key,
    this.header,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.of(context).size.width;
        final drawerWidth = BreakpointUtils.getSidebarWidth(width);
        
        return SizedBox(
          width: drawerWidth,
          child: Drawer(
            child: Column(
              children: [
                if (header != null) header!,
                Expanded(
                  child: ListView(
                    padding: padding ?? const EdgeInsets.all(0),
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A navigation item for adaptive drawer
class AdaptiveDrawerItem extends StatelessWidget {
  final AdaptiveNavigationItem item;
  final bool selected;
  final VoidCallback? onTap;
  
  const AdaptiveDrawerItem({
    super.key,
    required this.item,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Stack(
        children: [
          Icon(
            selected ? (item.selectedIcon ?? item.icon) : item.icon,
            color: selected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface,
          ),
          if (item.badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: item.badge!,
            ),
        ],
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: selected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: onTap ?? item.onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}