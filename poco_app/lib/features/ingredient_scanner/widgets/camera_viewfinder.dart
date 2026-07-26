import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';

class CameraViewfinder extends StatelessWidget {
  const CameraViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.white38),
            SizedBox(height: 16),
            Text('Point at ingredients', style: TextStyle(color: Colors.white60, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
