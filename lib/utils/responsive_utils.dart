import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }
  
  static double getCalendarWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return width * 0.95; // 95% of screen width on mobile
    } else if (width < 900) {
      return width * 0.8; // 80% of screen width on tablet
    } else {
      return 800; // Fixed width on desktop
    }
  }
  
  static EdgeInsets getPagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else {
      return 28.0;
    }
  }
  
  static double getFontSize(BuildContext context, {required FontSize size}) {
    if (isMobile(context)) {
      switch (size) {
        case FontSize.small:
          return 12.0;
        case FontSize.medium:
          return 14.0;
        case FontSize.large:
          return 16.0;
        case FontSize.xlarge:
          return 20.0;
      }
    } else if (isTablet(context)) {
      switch (size) {
        case FontSize.small:
          return 14.0;
        case FontSize.medium:
          return 16.0;
        case FontSize.large:
          return 18.0;
        case FontSize.xlarge:
          return 24.0;
      }
    } else {
      switch (size) {
        case FontSize.small:
          return 14.0;
        case FontSize.medium:
          return 16.0;
        case FontSize.large:
          return 20.0;
        case FontSize.xlarge:
          return 28.0;
      }
    }
  }
}

enum FontSize { small, medium, large, xlarge }