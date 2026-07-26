import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class ScannerViewfinder extends StatelessWidget {
  final bool isScanning;
  final List<Rect> detectedItems;

  const ScannerViewfinder({
    super.key,
    this.isScanning = false,
    this.detectedItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight * 0.55,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.camera_alt, size: 64, color: Colors.white.withAlpha(76)),
              ),
              if (isScanning)
                Positioned(
                  left: 0, right: 0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, child) {
                      return Container(
                        height: 2,
                        margin: EdgeInsets.only(top: value * 300),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, AppColors.primaryContainer, Colors.transparent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryContainer.withAlpha(76),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ...detectedItems.map((rect) => Positioned(
                left: rect.left,
                top: rect.top,
                child: Container(
                  width: rect.width,
                  height: rect.height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryContainer.withAlpha(179),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryContainer.withAlpha(51),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ),
              )),
              Positioned(
                bottom: 16,
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      isScanning ? 'Scanning ingredients...' : 'Tap to capture',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
