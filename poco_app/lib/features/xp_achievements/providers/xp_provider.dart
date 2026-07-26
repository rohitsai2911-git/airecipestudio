import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/completion_result.dart';

final xpProvider = StateProvider<int>((ref) => 1250);
final levelProvider = StateProvider<int>((ref) => 7);
final xpToNextLevelProvider = StateProvider<int>((ref) => 2000);

void applyCompletion(Ref ref, CompletionResult result) {
  ref.read(xpProvider.notifier).state = result.xp;
  ref.read(levelProvider.notifier).state = result.level;
  ref.read(xpToNextLevelProvider.notifier).state = 2000;
}
