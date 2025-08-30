import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingLiquidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String? tooltip;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableHoverEffect;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const FloatingLiquidButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.tooltip,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enableHoverEffect = true,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<FloatingLiquidButton> createState() => _FloatingLiquidButtonState();
}

class _FloatingLiquidButtonState extends State<FloatingLiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _shadowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
    
    _shadowAnimation = Tween<double>(
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

  void _onTapDown(TapDownDetails details) {
    if (widget.enableAnimation) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableAnimation) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableAnimation) {
      _animationController.reverse();
    }
  }

  void _onHover(bool isHovered) {
    if (widget.enableHoverEffect) {
      setState(() {
        _isHovered = isHovered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = widget.backgroundColor ?? 
        (isDark ? theme.colorScheme.primary : theme.colorScheme.primary);
    final foregroundColor = widget.foregroundColor ?? 
        (isDark ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimary);

    Widget button = Container(
      width: widget.width ?? 56.0,
      height: widget.height ?? 56.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: _isHovered ? 20 : 12,
            spreadRadius: _isHovered ? 2 : 0,
            offset: Offset(0, _isHovered ? 8 : 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: IconTheme(
              data: IconThemeData(
                color: foregroundColor,
                size: 24,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    // Add hover effect if enabled
    if (widget.enableHoverEffect) {
      button = MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: button,
      );
    }

    // Add animation if enabled
    if (widget.enableAnimation) {
      button = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Opacity(
                opacity: _shadowAnimation.value,
                child: child,
              ),
            ),
          );
        },
        child: button,
      );
    }

    // Add entrance animation
    if (widget.enableAnimation) {
      button = button.animate().fadeIn(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ).scale(
        begin: const Offset(0.5, 0.5),
        end: const Offset(1.0, 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
      );
    }

    // Wrap with tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// Specialized floating liquid buttons for common use cases
class FloatingLiquidIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool enableAnimation;
  final bool enableHoverEffect;
  final double? size;

  const FloatingLiquidIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.enableAnimation = true,
    this.enableHoverEffect = true,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingLiquidButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip,
      enableAnimation: enableAnimation,
      enableHoverEffect: enableHoverEffect,
      width: size,
      height: size,
      child: Icon(icon),
    );
  }
}

class FloatingLiquidTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool enableAnimation;
  final bool enableHoverEffect;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const FloatingLiquidTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.enableAnimation = true,
    this.enableHoverEffect = true,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingLiquidButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip,
      enableAnimation: enableAnimation,
      enableHoverEffect: enableHoverEffect,
      width: width,
      height: height,
      padding: padding,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}

// Extended floating action button with liquid effects
class ExtendedFloatingLiquidButton extends StatelessWidget {
  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final bool enableAnimation;
  final bool enableHoverEffect;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const ExtendedFloatingLiquidButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.enableAnimation = true,
    this.enableHoverEffect = true,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = this.backgroundColor ?? 
        (isDark ? theme.colorScheme.primary : theme.colorScheme.primary);
    final foregroundColor = this.foregroundColor ?? 
        (isDark ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimary);

    return Container(
      width: width,
      height: height ?? 56.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: IconThemeData(
                    color: foregroundColor,
                    size: 24,
                  ),
                  child: icon,
                ),
                const SizedBox(width: 12),
                DefaultTextStyle(
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  child: label,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    ).slideX(
      begin: 0.3,
      end: 0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }
}
