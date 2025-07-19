import 'package:flutter/material.dart';
import '../utils/breakpoint_utils.dart';

/// A grid widget that adapts its column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        int columns;
        switch (deviceType) {
          case DeviceType.mobile:
            columns = mobileColumns ?? 1;
            break;
          case DeviceType.tablet:
            columns = tabletColumns ?? 2;
            break;
          case DeviceType.desktop:
            columns = desktopColumns ?? BreakpointUtils.getGridColumns(width);
            break;
        }
        
        return GridView.builder(
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          scrollDirection: scrollDirection,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// A sliver grid widget that adapts its column count based on screen size
class ResponsiveSliverGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  
  const ResponsiveSliverGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        int columns;
        switch (deviceType) {
          case DeviceType.mobile:
            columns = mobileColumns ?? 1;
            break;
          case DeviceType.tablet:
            columns = tabletColumns ?? 2;
            break;
          case DeviceType.desktop:
            columns = desktopColumns ?? BreakpointUtils.getGridColumns(width);
            break;
        }
        
        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => children[index],
            childCount: children.length,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
        );
      },
    );
  }
}

/// A staggered grid widget that adapts to screen size
class ResponsiveStaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  
  const ResponsiveStaggeredGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        int columns;
        switch (deviceType) {
          case DeviceType.mobile:
            columns = mobileColumns ?? 1;
            break;
          case DeviceType.tablet:
            columns = tabletColumns ?? 2;
            break;
          case DeviceType.desktop:
            columns = desktopColumns ?? BreakpointUtils.getGridColumns(width);
            break;
        }
        
        // Create a simple staggered layout using Wrap
        return SingleChildScrollView(
          padding: padding,
          physics: physics,
          child: _buildStaggeredLayout(columns),
        );
      },
    );
  }
  
  Widget _buildStaggeredLayout(int columns) {
    if (columns == 1) {
      return Column(
        children: children.map((child) => Padding(
          padding: EdgeInsets.only(bottom: mainAxisSpacing),
          child: child,
        )).toList(),
      );
    }
    
    // Create column lists
    final columnChildren = List.generate(columns, (index) => <Widget>[]);
    
    // Distribute children across columns
    for (int i = 0; i < children.length; i++) {
      final columnIndex = i % columns;
      columnChildren[columnIndex].add(children[i]);
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChildren.asMap().entries.map((entry) {
        final columnIndex = entry.key;
        final columnWidgets = entry.value;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: columnIndex > 0 ? crossAxisSpacing / 2 : 0,
              right: columnIndex < columns - 1 ? crossAxisSpacing / 2 : 0,
            ),
            child: Column(
              children: columnWidgets.map((child) => Padding(
                padding: EdgeInsets.only(bottom: mainAxisSpacing),
                child: child,
              )).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// A responsive wrap widget that adjusts spacing based on screen size
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? mobileRunSpacing;
  final double? tabletRunSpacing;
  final double? desktopRunSpacing;
  
  const ResponsiveWrap({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.mobileRunSpacing,
    this.tabletRunSpacing,
    this.desktopRunSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        double spacing;
        double runSpacing;
        
        switch (deviceType) {
          case DeviceType.mobile:
            spacing = mobileSpacing ?? 8.0;
            runSpacing = mobileRunSpacing ?? 8.0;
            break;
          case DeviceType.tablet:
            spacing = tabletSpacing ?? 12.0;
            runSpacing = tabletRunSpacing ?? 12.0;
            break;
          case DeviceType.desktop:
            spacing = desktopSpacing ?? 16.0;
            runSpacing = desktopRunSpacing ?? 16.0;
            break;
        }
        
        return Wrap(
          direction: direction,
          alignment: alignment,
          runAlignment: runAlignment,
          crossAxisAlignment: crossAxisAlignment,
          spacing: spacing,
          runSpacing: runSpacing,
          children: children,
        );
      },
    );
  }
}

/// A responsive card widget that adapts its width based on screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
    this.clipBehavior = Clip.none,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(screenWidth);
        
        double? cardWidth;
        switch (deviceType) {
          case DeviceType.mobile:
            cardWidth = mobileWidth ?? BreakpointUtils.getCardWidth(screenWidth);
            break;
          case DeviceType.tablet:
            cardWidth = tabletWidth ?? BreakpointUtils.getCardWidth(screenWidth);
            break;
          case DeviceType.desktop:
            cardWidth = desktopWidth ?? BreakpointUtils.getCardWidth(screenWidth);
            break;
        }
        
        return Container(
          width: cardWidth,
          margin: margin,
          child: Card(
            color: color,
            elevation: elevation,
            shape: shape,
            clipBehavior: clipBehavior,
            child: padding != null 
                ? Padding(padding: padding!, child: child)
                : child,
          ),
        );
      },
    );
  }
}