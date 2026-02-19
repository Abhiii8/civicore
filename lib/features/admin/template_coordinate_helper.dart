/// CiviCore - Template Coordinate Helper
/// 
/// Helper to convert between screen coordinates and image coordinates

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class TemplateCoordinateHelper {
  // Get actual image dimensions
  static Future<Size> getImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        return Size(image.width.toDouble(), image.height.toDouble());
      }
    } catch (e) {
      print('Error getting image size: $e');
    }
    return Size.zero;
  }

  // Convert screen coordinates to image coordinates
  // When image is displayed with BoxFit.contain, it may be scaled
  static Offset convertToImageCoordinates(
    Offset screenPosition,
    Size containerSize,
    Size imageSize,
  ) {
    // Calculate displayed image size (BoxFit.contain)
    final imageAspect = imageSize.width / imageSize.height;
    final containerAspect = containerSize.width / containerSize.height;
    
    double displayedWidth, displayedHeight, offsetX, offsetY;
    
    if (imageAspect > containerAspect) {
      // Image is wider - fit to width
      displayedWidth = containerSize.width;
      displayedHeight = containerSize.width / imageAspect;
      offsetX = 0;
      offsetY = (containerSize.height - displayedHeight) / 2;
    } else {
      // Image is taller - fit to height
      displayedWidth = containerSize.height * imageAspect;
      displayedHeight = containerSize.height;
      offsetX = (containerSize.width - displayedWidth) / 2;
      offsetY = 0;
    }
    
    // Convert screen position to image position
    final relativeX = screenPosition.dx - offsetX;
    final relativeY = screenPosition.dy - offsetY;
    
    // Scale to actual image dimensions
    final imageX = (relativeX / displayedWidth) * imageSize.width;
    final imageY = (relativeY / displayedHeight) * imageSize.height;
    
    return Offset(imageX, imageY);
  }

  // Convert image coordinates to screen coordinates (for displaying indicators)
  static Offset convertToScreenCoordinates(
    Offset imagePosition,
    Size containerSize,
    Size imageSize,
  ) {
    // Calculate displayed image size (BoxFit.contain)
    final imageAspect = imageSize.width / imageSize.height;
    final containerAspect = containerSize.width / containerSize.height;
    
    double displayedWidth, displayedHeight, offsetX, offsetY;
    
    if (imageAspect > containerAspect) {
      displayedWidth = containerSize.width;
      displayedHeight = containerSize.width / imageAspect;
      offsetX = 0;
      offsetY = (containerSize.height - displayedHeight) / 2;
    } else {
      displayedWidth = containerSize.height * imageAspect;
      displayedHeight = containerSize.height;
      offsetX = (containerSize.width - displayedWidth) / 2;
      offsetY = 0;
    }
    
    // Convert image position to screen position
    final screenX = (imagePosition.dx / imageSize.width) * displayedWidth + offsetX;
    final screenY = (imagePosition.dy / imageSize.height) * displayedHeight + offsetY;
    
    return Offset(screenX, screenY);
  }
}
