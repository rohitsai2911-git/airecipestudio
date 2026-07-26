import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LibrarySearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const LibrarySearchBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController.fromValue(TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    ));
    return TextField(
      controller: controller,
      onChanged: (v) {
        onChanged(v);
        controller.selection = TextSelection.collapsed(offset: v.length);
      },
      decoration: InputDecoration(
        hintText: 'Search recipes...',
        prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant),
                onPressed: () => onChanged(''),
              )
            : null,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
    );
  }
}
