import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();
  static const card = BoxShadow(
    color: Color(0x0D2D2D2D), offset: Offset(0, 10), blurRadius: 30,
  );
  static const bottomNav = BoxShadow(
    color: Color(0x0D2D2D2D), offset: Offset(0, -10), blurRadius: 30,
  );
  static const onboardingCard = BoxShadow(
    color: Color(0x0D2D2D2D), offset: Offset(0, 10), blurRadius: 30,
  );
  static const mascotCard = BoxShadow(
    color: Color(0x14AB3500), offset: Offset(0, 20), blurRadius: 50,
  );
  static const vibrantButton = BoxShadow(
    color: Color(0xFF832600), offset: Offset(0, 4), blurRadius: 0,
  );
  static const voiceNext = BoxShadow(
    color: Color(0x33AB3500), offset: Offset(0, 10), blurRadius: 30,
  );
  static const sheet = BoxShadow(
    color: Color(0x1A000000), offset: Offset(0, -20), blurRadius: 50,
  );
  static const glowOrange = BoxShadow(
    color: Color(0x26FF6B35), offset: Offset(0, 0), blurRadius: 20,
  );
  static const progressGlow = BoxShadow(
    color: Color(0x66FF6B35), offset: Offset(0, 0), blurRadius: 15,
  );
}
