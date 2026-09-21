import '../utils/common_imports.dart';

class TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TypeChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.orange : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? AppFonts.w500w16.copyWith(fontSize: 13)
              : AppFonts.w500g14.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}
