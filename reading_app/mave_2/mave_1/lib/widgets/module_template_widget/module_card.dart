import '../../Utils/Common_imports/common_imports.dart';

class ModuleCard extends StatefulWidget {
  final String title;
  final double progress;
  final VoidCallback onTap;
  final bool isActive;

  ModuleCard({
    required this.title,
    required this.progress,
    required this.onTap,
    this.isActive = true,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _setupBreathAnimation();
  }

  void _setupBreathAnimation() {
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _breathAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    if (widget.isActive) _breathController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ModuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_breathController.isAnimating) {
      _breathController.repeat(reverse: true);
    } else if (!widget.isActive && _breathController.isAnimating) {
      _breathController.stop();
      _breathController.reset();
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        double breathScale = widget.isActive ? _breathAnimation.value : 1.0;
        return Transform.scale(scale: breathScale, child: child);
      },
      child: AnimatedScale(
        scale: widget.isActive ? 1.0 : 0.8,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 400),
          opacity: widget.isActive ? 1.0 : 0.5,
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 401,
        height: 184,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFD9D9D9).withOpacity(0.85),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProgressBar(),
            SizedBox(height: 10),
            _buildTitleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 332,
      height: 35,
      decoration: BoxDecoration(
        color: Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: 332 * widget.progress,
            decoration: BoxDecoration(
              color: AppColors.progressBarFill,
              borderRadius: BorderRadius.circular(50),
              border: widget.progress > 0
                  ? Border.all(color: AppColors.progressBarStroke, width: 2)
                  : null,
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(Icons.star, color: Color(0xFFFFD700), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleButton() {
    return Container(
      width: 342,
      height: 95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        border: Border.all(color: Color(0xFFCCA7DA), width: 9),
        image: DecorationImage(
          image: AssetImage('lib/assets/images/module_background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(child: Text(widget.title, style: AppFonts.primaryText())),
    );
  }
}
