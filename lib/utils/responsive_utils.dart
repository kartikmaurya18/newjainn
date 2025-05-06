// utils/responsive_utils.dart
import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < 600;
  
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 && 
      MediaQuery.of(context).size.width < 1200;
  
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= 1200;
  
  // Get value based on screen size
  static double value(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200) {
      return desktop ?? tablet ?? mobile;
    } else if (screenWidth >= 600) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
  
  // Get font size based on screen size
  static double fontSize(BuildContext context, {
    required double base,
    double factor = 0.3,
  }) {
    if (isMobile(context)) {
      return base;
    } else if (isTablet(context)) {
      return base * (1 + factor);
    } else {
      return base * (1 + factor * 2);
    }
  }
  
  // Get padding based on screen size
  static EdgeInsets padding(BuildContext context, {
    required double base,
    double factor = 0.5,
  }) {
    if (isMobile(context)) {
      return EdgeInsets.all(base);
    } else if (isTablet(context)) {
      return EdgeInsets.all(base * (1 + factor));
    } else {
      return EdgeInsets.all(base * (1 + factor * 2));
    }
  }
}