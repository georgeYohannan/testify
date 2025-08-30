import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidBackground extends StatefulWidget {
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;
  final bool enableAnimation;
  final Duration animationDuration;

  const LiquidBackground({
    super.key,
    required this.child,
    this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.enableAnimation = true,
    this.animationDuration = const Duration(seconds: 20),
  });

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late AnimationController _tertiaryController;
  
  late Animation<double> _primaryAnimation;
  late Animation<double> _secondaryAnimation;
  late Animation<double> _tertiaryAnimation;

  @override
  void initState() {
    super.initState();
    
    _primaryController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _secondaryController = AnimationController(
      duration: widget.animationDuration * 1.5,
      vsync: this,
    );
    
    _tertiaryController = AnimationController(
      duration: widget.animationDuration * 0.8,
      vsync: this,
    );

    _primaryAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _primaryController,
      curve: Curves.easeInOut,
    ));

    _secondaryAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _secondaryController,
      curve: Curves.easeInOut,
    ));

    _tertiaryAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _tertiaryController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableAnimation) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _primaryController.repeat();
    _secondaryController.repeat();
    _tertiaryController.repeat();
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _tertiaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final primaryColor = widget.primaryColor ?? 
        (isDark ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.1));
    final secondaryColor = widget.secondaryColor ?? 
        (isDark ? theme.colorScheme.secondary : theme.colorScheme.secondary.withValues(alpha: 0.1));
    final tertiaryColor = widget.tertiaryColor ?? 
        (isDark ? theme.colorScheme.tertiary : theme.colorScheme.tertiary.withValues(alpha: 0.1));

    return Stack(
      children: [
        // Animated background shapes
        if (widget.enableAnimation) ...[
          // Primary floating blob
          AnimatedBuilder(
            animation: _primaryAnimation,
            builder: (context, child) {
              return Positioned(
                left: 50 + 30 * math.cos(_primaryAnimation.value),
                top: 100 + 40 * math.sin(_primaryAnimation.value * 0.7),
                child: _buildBlob(
                  size: 200,
                  color: primaryColor,
                  blurRadius: 80,
                ),
              );
            },
          ),
          
          // Secondary floating blob
          AnimatedBuilder(
            animation: _secondaryAnimation,
            builder: (context, child) {
              return Positioned(
                right: 80 + 50 * math.cos(_secondaryAnimation.value * 0.8),
                top: 300 + 60 * math.sin(_secondaryAnimation.value * 1.2),
                child: _buildBlob(
                  size: 150,
                  color: secondaryColor,
                  blurRadius: 60,
                ),
              );
            },
          ),
          
          // Tertiary floating blob
          AnimatedBuilder(
            animation: _tertiaryAnimation,
            builder: (context, child) {
              return Positioned(
                left: 200 + 40 * math.cos(_tertiaryAnimation.value * 1.5),
                bottom: 150 + 50 * math.sin(_tertiaryAnimation.value * 0.9),
                child: _buildBlob(
                  size: 180,
                  color: tertiaryColor,
                  blurRadius: 70,
                ),
              );
            },
          ),
        ] else ...[
          // Static background shapes
          Positioned(
            left: 50,
            top: 100,
            child: _buildBlob(
              size: 200,
              color: primaryColor,
              blurRadius: 80,
            ),
          ),
          Positioned(
            right: 80,
            top: 300,
            child: _buildBlob(
              size: 150,
              color: secondaryColor,
              blurRadius: 60,
            ),
          ),
          Positioned(
            left: 200,
            bottom: 150,
            child: _buildBlob(
              size: 180,
              color: tertiaryColor,
              blurRadius: 70,
            ),
          ),
        ],
        
        // Content
        widget.child,
      ],
    );
  }

  Widget _buildBlob({
    required double size,
    required Color color,
    required double blurRadius,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: blurRadius,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}

class GradientLiquidBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final bool enableAnimation;

  const GradientLiquidBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin,
    this.end,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
          final defaultColors = colors ?? [
        if (isDark) ...[
          theme.colorScheme.primary.withValues(alpha: 0.1),
          theme.colorScheme.secondary.withValues(alpha: 0.1),
          theme.colorScheme.tertiary.withValues(alpha: 0.1),
        ] else ...[
          theme.colorScheme.primary.withValues(alpha: 0.05),
          theme.colorScheme.secondary.withValues(alpha: 0.05),
          theme.colorScheme.tertiary.withValues(alpha: 0.05),
        ],
      ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
          colors: defaultColors,
        ),
      ),
      child: enableAnimation
          ? LiquidBackground(
              enableAnimation: true,
              child: child,
            )
          : child,
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;
  final Curve curve;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
          final defaultColors = widget.colors ?? [
        if (isDark) ...[
          theme.colorScheme.primary.withValues(alpha: 0.15),
          theme.colorScheme.secondary.withValues(alpha: 0.15),
          theme.colorScheme.tertiary.withValues(alpha: 0.15),
          theme.colorScheme.primary.withValues(alpha: 0.15),
        ] else ...[
          theme.colorScheme.primary.withValues(alpha: 0.08),
          theme.colorScheme.secondary.withValues(alpha: 0.08),
          theme.colorScheme.tertiary.withValues(alpha: 0.08),
          theme.colorScheme.primary.withValues(alpha: 0.08),
        ],
      ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: defaultColors,
              stops: [
                0.0,
                _animation.value,
                (_animation.value + 0.5) % 1.0,
                1.0,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
