import 'package:flutter/material.dart';

class ElephantMascot extends StatefulWidget {
  final ElephantState state;
  final double size;
  final String? message;

  const ElephantMascot({
    super.key,
    this.state = ElephantState.neutral,
    this.size = 120,
    this.message,
  });

  @override
  State<ElephantMascot> createState() => _ElephantMascotState();
}

class _ElephantMascotState extends State<ElephantMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ));

    _triggerAnimation();
  }

  void _triggerAnimation() {
    if (widget.state == ElephantState.correct || 
        widget.state == ElephantState.encouraging) {
      _animationController.repeat(reverse: true);
    } else if (widget.state == ElephantState.incorrect) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void didUpdateWidget(ElephantMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _animationController.reset();
      _triggerAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getElephantImage() {
    switch (widget.state) {
      case ElephantState.correct:
      case ElephantState.encouraging:
        return 'https://pixabay.com/get/g630780b2826f15d31322941a9d01432ecffff77217876b910770b899a7d38bcfcae51e917be91e451947880b1532c95dc67f4c5c77e473252f866592b2bf2a21_1280.jpg'; // Happy elephant
      case ElephantState.incorrect:
        return 'https://pixabay.com/get/gd39b2c4ba8ae2972ee7d8f0b29d60994291020abf8520e7e9f184eace017b76692a5d1555baf9fb8ed65c14cf5af2de691c07e82be454907dbf50034543fd532_1280.png'; // Sad elephant
      case ElephantState.neutral:
      default:
        return 'https://pixabay.com/get/g7b7e2a191870be4b37f19f29415c6885ea804c95ca2b950fe9eb49fed7c947b318561ec0027d82980c84a307fe6bd1183cf125cdaf2ce005cf5ccc2d87273930_1280.jpg'; // Neutral elephant
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.state) {
      case ElephantState.correct:
        return theme.colorScheme.tertiary.withValues(alpha: 0.1);
      case ElephantState.incorrect:
        return theme.colorScheme.error.withValues(alpha: 0.1);
      case ElephantState.encouraging:
        return theme.colorScheme.secondary.withValues(alpha: 0.1);
      case ElephantState.neutral:
      default:
        return theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(widget.size / 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    child: Image.network(
                      _getElephantImage(),
                      width: widget.size * 0.8,
                      height: widget.size * 0.8,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to emoji if image fails to load
                        return Container(
                          width: widget.size * 0.8,
                          height: widget.size * 0.8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(widget.size * 0.4),
                          ),
                          child: Center(
                            child: Text(
                              '🐘',
                              style: TextStyle(fontSize: widget.size * 0.4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.message != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      widget.message!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

enum ElephantState {
  neutral,
  correct,
  incorrect,
  encouraging,
}