import 'package:flutter/material.dart';
import '../utils/breakpoint_utils.dart';
import 'responsive_layout.dart';
import 'responsive_grid.dart';
import 'adaptive_navigation.dart';

/// Demo widget showcasing all responsive components
class ResponsiveDemo extends StatefulWidget {
  const ResponsiveDemo({super.key});

  @override
  State<ResponsiveDemo> createState() => _ResponsiveDemoState();
}

class _ResponsiveDemoState extends State<ResponsiveDemo> {
  int _currentIndex = 0;

  final List<AdaptiveNavigationItem> _navigationItems = [
    const AdaptiveNavigationItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      route: '/home',
    ),
    const AdaptiveNavigationItem(
      label: 'Groups',
      icon: Icons.group_outlined,
      selectedIcon: Icons.group,
      route: '/groups',
      badge: Badge(
        label: Text('3'),
        child: SizedBox.shrink(),
      ),
    ),
    const AdaptiveNavigationItem(
      label: 'Community',
      icon: Icons.forum_outlined,
      selectedIcon: Icons.forum,
      route: '/community',
    ),
    const AdaptiveNavigationItem(
      label: 'Rankings',
      icon: Icons.leaderboard_outlined,
      selectedIcon: Icons.leaderboard,
      route: '/rankings',
    ),
    const AdaptiveNavigationItem(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      navigationItems: _navigationItems,
      currentIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      appBar: AppBar(
        title: const ResponsiveText(
          'Responsive Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResponsiveSpacing.vertical(),
            
            // Device Info Section
            _buildDeviceInfoSection(),
            
            const ResponsiveSpacing.vertical(),
            
            // Responsive Grid Section
            _buildGridSection(),
            
            const ResponsiveSpacing.vertical(),
            
            // Responsive Cards Section
            _buildCardsSection(),
            
            const ResponsiveSpacing.vertical(),
            
            // Responsive Wrap Section
            _buildWrapSection(),
            
            const ResponsiveSpacing.vertical(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoSection() {
    return ResponsiveBuilder(
      builder: (context, deviceType, screenSize) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(BreakpointUtils.getScreenPadding(screenSize.width)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Device Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Device Type', deviceType.name.toUpperCase()),
                _buildInfoRow('Screen Width', '${screenSize.width.toInt()}px'),
                _buildInfoRow('Screen Height', '${screenSize.height.toInt()}px'),
                _buildInfoRow('Grid Columns', '${BreakpointUtils.getGridColumns(screenSize.width)}'),
                _buildInfoRow('Sidebar Width', '${BreakpointUtils.getSidebarWidth(screenSize.width).toInt()}px'),
                _buildInfoRow('Touch Friendly', BreakpointUtils.shouldUseTouchFriendlySpacing(screenSize.width) ? 'Yes' : 'No'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Responsive Grid',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          mobileColumns: 1,
          tabletColumns: 2,
          desktopColumns: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(8, (index) => Card(
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.widgets,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text('Item ${index + 1}'),
                ],
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Responsive Cards',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ResponsiveWrap(
          children: List.generate(6, (index) => ResponsiveCard(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Card ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a responsive card that adapts its width based on screen size.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildWrapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Responsive Wrap',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        ResponsiveWrap(
          mobileSpacing: 8,
          tabletSpacing: 12,
          desktopSpacing: 16,
          children: List.generate(12, (index) => Chip(
            label: Text('Tag ${index + 1}'),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          )),
        ),
      ],
    );
  }
}

/// Example of a responsive layout with different layouts for different screen sizes
class ResponsiveLayoutExample extends StatelessWidget {
  const ResponsiveLayoutExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return const Column(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Mobile Layout - Single Column'),
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Content stacked vertically'),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Tablet Layout - Main Content'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: const [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Sidebar 1'),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Sidebar 2'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        const Expanded(
          flex: 1,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Desktop Layout - Left Sidebar'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          flex: 3,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Main Content Area'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: const [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Right Panel 1'),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Right Panel 2'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}