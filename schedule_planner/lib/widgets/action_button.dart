import '../utils/common_imports.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade900 : AppColors.orange,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppFonts.w600w18.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
