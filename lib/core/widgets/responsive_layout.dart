import 'package:flutter/material.dart';
import '../utils/breakpoint_utils.dart';

/// A widget that provides different layouts based on screen size
class ResponsiveLayout extends StatelessWidget {
  /// Layout for mobile devices (< 600px)
  final Widget mobile;
  
  /// Layout for tablet devices (600px - 1024px)
  final Widget? tablet;
  
  /// Layout for desktop devices (>= 1024px)
  final Widget? desktop;
  
  /// Optional custom breakpoints
  final double? mobileBreakpoint;
  final double? tabletBreakpoint;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint,
    this.tabletBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mobileBreak = mobileBreakpoint ?? BreakpointUtils.mobileBreakpoint;
        final tabletBreak = tabletBreakpoint ?? BreakpointUtils.tabletBreakpoint;
        
        if (width >= tabletBreak) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= mobileBreak) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A builder widget that provides device type and screen dimensions
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    DeviceType deviceType,
    Size screenSize,
  ) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = BreakpointUtils.getDeviceType(constraints.maxWidth);
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        return builder(context, deviceType, screenSize);
      },
    );
  }
}

/// A widget that adapts its child's properties based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double? desktopMaxWidth;
  final AlignmentGeometry alignment;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        EdgeInsetsGeometry padding;
        double? maxWidth;
        
        switch (deviceType) {
          case DeviceType.mobile:
            padding = mobilePadding ?? 
                EdgeInsets.all(BreakpointUtils.getScreenPadding(width));
            maxWidth = mobileMaxWidth;
            break;
          case DeviceType.tablet:
            padding = tabletPadding ?? 
                EdgeInsets.all(BreakpointUtils.getScreenPadding(width));
            maxWidth = tabletMaxWidth;
            break;
          case DeviceType.desktop:
            padding = desktopPadding ?? 
                EdgeInsets.all(BreakpointUtils.getScreenPadding(width));
            maxWidth = desktopMaxWidth ?? 
                BreakpointUtils.getContentMaxWidth(width);
            break;
        }
        
        return Container(
          alignment: alignment,
          padding: padding,
          child: maxWidth != null
              ? ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                )
              : child,
        );
      },
    );
  }
}

/// A widget that provides responsive spacing
class ResponsiveSpacing extends StatelessWidget {
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final Axis direction;
  
  const ResponsiveSpacing({
    super.key,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.direction = Axis.vertical,
  });
  
  /// Creates vertical spacing
  const ResponsiveSpacing.vertical({
    super.key,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
  }) : direction = Axis.vertical;
  
  /// Creates horizontal spacing
  const ResponsiveSpacing.horizontal({
    super.key,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
  }) : direction = Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use MediaQuery width if constraints are infinite or too large
        final screenWidth = MediaQuery.of(context).size.width;
        final width = constraints.maxWidth == double.infinity || constraints.maxWidth > screenWidth
            ? screenWidth
            : constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        double spacing;
        switch (deviceType) {
          case DeviceType.mobile:
            spacing = mobileSpacing ?? BreakpointUtils.getElementSpacing(width);
            break;
          case DeviceType.tablet:
            spacing = tabletSpacing ?? BreakpointUtils.getElementSpacing(width);
            break;
          case DeviceType.desktop:
            spacing = desktopSpacing ?? BreakpointUtils.getElementSpacing(width);
            break;
        }
        
        return direction == Axis.vertical
            ? SizedBox(height: spacing)
            : SizedBox(width: spacing);
      },
    );
  }
}

/// A responsive text widget that scales based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? mobileScaleFactor;
  final double? tabletScaleFactor;
  final double? desktopScaleFactor;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mobileScaleFactor,
    this.tabletScaleFactor,
    this.desktopScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = BreakpointUtils.getDeviceType(width);
        
        double scaleFactor;
        switch (deviceType) {
          case DeviceType.mobile:
            scaleFactor = mobileScaleFactor ?? 1.0;
            break;
          case DeviceType.tablet:
            scaleFactor = tabletScaleFactor ?? 1.1;
            break;
          case DeviceType.desktop:
            scaleFactor = desktopScaleFactor ?? 1.2;
            break;
        }
        
        final effectiveStyle = style != null
            ? style!.copyWith(
                fontSize: (style!.fontSize ?? 14.0) * scaleFactor,
              )
            : TextStyle(fontSize: 14.0 * scaleFactor);
        
        return Text(
          text,
          style: effectiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}