import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/models/product_comparison.dart';
import '../../../../core/theme/app_theme.dart';

class BeforeAfterSlider extends StatefulWidget {
  final ProductComparison comparison;

  const BeforeAfterSlider({
    super.key,
    required this.comparison,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5; // 0.0 = all before, 1.0 = all after

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          widget.comparison.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 16),

        // Interactive Comparison
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      // Calculate slider position based on local position
                      _sliderPosition =
                          (details.localPosition.dx / constraints.maxWidth)
                              .clamp(0.0, 1.0);
                    });
                  },
                  onTapDown: (details) {
                    setState(() {
                      // Allow tapping to set position
                      _sliderPosition =
                          (details.localPosition.dx / constraints.maxWidth)
                              .clamp(0.0, 1.0);
                    });
                  },
                  child: Stack(
                    children: [
                      // Before Image (Full width) - RIGHT SIDE
                      Positioned.fill(
                        child: _buildImagePlaceholder(
                          widget.comparison.beforeLabel,
                          Colors.red.shade100,
                          widget.comparison.beforeImageUrl,
                        ),
                      ),

                      // After Image (Clipped based on slider) - LEFT SIDE
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: constraints.maxWidth * _sliderPosition,
                        child: ClipRect(
                          child: _buildImagePlaceholder(
                            widget.comparison.afterLabel,
                            Colors.green.shade100,
                            widget.comparison.afterImageUrl,
                          ),
                        ),
                      ),

                      // Slider Handle
                      Positioned(
                        left: (constraints.maxWidth * _sliderPosition) - 20,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            width: 4,
                            color: Colors.white,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.compare_arrows,
                                  color: AppTheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Labels
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.comparison.afterLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.comparison.beforeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Instruction
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'Drag the slider to compare',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Descriptions
        Row(
          children: [
            Expanded(
              child: _buildDescriptionCard(
                widget.comparison.beforeLabel,
                widget.comparison.beforeDescription,
                Colors.red.shade50,
                Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDescriptionCard(
                widget.comparison.afterLabel,
                widget.comparison.afterDescription,
                Colors.green.shade50,
                Colors.green.shade700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Key Improvements
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accent.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: AppTheme.accent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Key Improvements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...widget.comparison.improvements.map((improvement) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppTheme.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            improvement,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.text,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(String label, Color color, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Display actual product image
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to placeholder if image fails to load
          return _buildPlaceholderContent(label, color);
        },
      );
    }

    // Show placeholder when no image URL provided
    return _buildPlaceholderContent(label, color);
  }

  Widget _buildPlaceholderContent(String label, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Product Image',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(
    String title,
    String description,
    Color bgColor,
    Color titleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
