import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:testify/theme.dart';

class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.blurRadius = 20.0,
    this.backgroundColor,
    this.borderColor,
    this.shadows,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.onTap,
    this.enableHoverEffect = true,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (widget.enableHoverEffect) {
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine glass decoration based on theme
    BoxDecoration glassDecoration;
    if (isDark) {
      glassDecoration = GlassDecorations.darkGlass(
        blurRadius: widget.blurRadius,
        borderRadius: widget.borderRadius,
        backgroundColor: widget.backgroundColor,
        borderColor: widget.borderColor,
      );
    } else {
      glassDecoration = GlassDecorations.lightGlass(
        blurRadius: widget.blurRadius,
        borderRadius: widget.borderRadius,
        backgroundColor: widget.backgroundColor,
        borderColor: widget.borderColor,
      );
    }

    // Add custom shadows if provided
    if (widget.shadows != null) {
      glassDecoration = glassDecoration.copyWith(
        boxShadow: widget.shadows,
      );
    }

    Widget container = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: glassDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    // Add hover effect if enabled
    if (widget.enableHoverEffect) {
      container = MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: container,
      );
    }

    // Add animation if enabled
    if (widget.enableAnimation) {
      container = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: container,
      );
    }

    // Add tap functionality if provided
    if (widget.onTap != null) {
      container = GestureDetector(
        onTap: widget.onTap,
        child: container,
      );
    }

    // Add entrance animation
    if (widget.enableAnimation) {
      container = container.animate().fadeIn(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ).slideY(
        begin: 0.3,
        end: 0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }

    return container;
  }
}

// Specialized liquid glass containers for common use cases
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.enableHoverEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      borderRadius: DesignTokens.radiusLg,
      blurRadius: 25.0,
      onTap: onTap,
      enableHoverEffect: enableHoverEffect,
      child: child,
    );
  }
}

class LiquidGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool enableHoverEffect;

  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.width,
    this.height,
    this.enableHoverEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return LiquidGlassContainer(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: DesignTokens.lg,
        vertical: DesignTokens.md,
      ),
      width: width,
      height: height,
      borderRadius: DesignTokens.radiusMd,
      blurRadius: 15.0,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.8),
      borderColor: theme.colorScheme.primary.withValues(alpha: 0.9),
      onTap: onPressed,
      enableHoverEffect: enableHoverEffect,
      child: child,
    );
  }
}

class LiquidGlassInput extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const LiquidGlassInput({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: DesignTokens.md,
      vertical: DesignTokens.sm,
    ),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassContainer(
      padding: padding,
      width: width,
      height: height,
      borderRadius: DesignTokens.radiusMd,
      blurRadius: 10.0,
      enableAnimation: false,
      enableHoverEffect: false,
      child: child,
    );
  }
}
