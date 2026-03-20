import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SyllableTile extends StatefulWidget {
  final String syllable;
  final bool isUsed;
  final VoidCallback? onTap;

  const SyllableTile({
    super.key,
    required this.syllable,
    this.isUsed = false,
    this.onTap,
  });

  @override
  State<SyllableTile> createState() => _SyllableTileState();
}

class _SyllableTileState extends State<SyllableTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isUsed || widget.onTap == null) return;
    _controller.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.isUsed
                ? Colors.grey.shade200
                : AppColors.tileDefault,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isUsed
                  ? Colors.grey.shade300
                  : AppColors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: widget.isUsed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.syllable,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isUsed ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
