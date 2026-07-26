import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingStepProvider = StateProvider<int>((_) => 0);

final onboardingCompleteProvider = StateProvider<bool>((_) => false);
