import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:testify/theme.dart';
import 'dart:ui';

class LiquidNavigationBar extends StatefulWidget {
  final List<LiquidNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableHoverEffect;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const LiquidNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enableHoverEffect = true,
    this.height,
    this.padding,
  });

  @override
  State<LiquidNavigationBar> createState() => _LiquidNavigationBarState();
}

class _LiquidNavigationBarState extends State<LiquidNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = widget.backgroundColor ?? 
        (isDark ? theme.colorScheme.surface.withValues(alpha: 0.9) : theme.colorScheme.surface.withValues(alpha: 0.9));
    final selectedItemColor = widget.selectedItemColor ?? theme.colorScheme.primary;
    final unselectedItemColor = widget.unselectedItemColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      height: widget.height ?? 80.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXl),
          topRight: Radius.circular(DesignTokens.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXl),
          topRight: Radius.circular(DesignTokens.radiusXl),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.symmetric(
              horizontal: DesignTokens.md,
              vertical: DesignTokens.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == widget.currentIndex;
                
                return _buildNavigationItem(
                  item: item,
                  index: index,
                  isSelected: isSelected,
                  selectedColor: selectedItemColor,
                  unselectedColor: unselectedItemColor,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ).animate().slideY(
      begin: 1.0,
      end: 0.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildNavigationItem({
    required LiquidNavigationBarItem item,
    required int index,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.md,
          vertical: DesignTokens.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          color: isSelected 
              ? selectedColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              padding: EdgeInsets.all(isSelected ? DesignTokens.sm : DesignTokens.xs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? selectedColor.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                item.icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: isSelected ? 28 : 24,
              ),
            ),
            const SizedBox(height: DesignTokens.xs),
            AnimatedDefaultTextStyle(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: isSelected ? 12 : 11,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidNavigationBarItem {
  final IconData icon;
  final String label;
  final Widget? badge;
  final String? tooltip;

  const LiquidNavigationBarItem({
    required this.icon,
    required this.label,
    this.badge,
    this.tooltip,
  });
}

// Modern bottom navigation bar with liquid effects
class ModernLiquidBottomNavigationBar extends StatelessWidget {
  final List<LiquidNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool enableAnimation;
  final bool enableHoverEffect;

  const ModernLiquidBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.enableAnimation = true,
    this.enableHoverEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      enableAnimation: enableAnimation,
      enableHoverEffect: enableHoverEffect,
    );
  }
}

// Floating navigation bar with liquid effects
class FloatingLiquidNavigationBar extends StatelessWidget {
  final List<LiquidNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool enableAnimation;
  final bool enableHoverEffect;
  final EdgeInsetsGeometry? margin;

  const FloatingLiquidNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.enableAnimation = true,
    this.enableHoverEffect = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(DesignTokens.lg),
      child: LiquidNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        enableAnimation: enableAnimation,
        enableHoverEffect: enableHoverEffect,
      ),
    );
  }
}

// Tab bar with liquid effects
class LiquidTabBar extends StatelessWidget {
  final List<LiquidNavigationBarItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool enableAnimation;
  final bool enableHoverEffect;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;

  const LiquidTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.enableAnimation = true,
    this.enableHoverEffect = true,
    this.isScrollable = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = this.backgroundColor ?? 
        (isDark ? theme.colorScheme.surface.withValues(alpha: 0.9) : theme.colorScheme.surface.withValues(alpha: 0.9));
    final selectedItemColor = this.selectedItemColor ?? theme.colorScheme.primary;
    final unselectedItemColor = this.unselectedItemColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(DesignTokens.sm),
            child: isScrollable
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tabs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tab = entry.value;
                        final isSelected = index == currentIndex;
                        
                        return _buildTabItem(
                          tab: tab,
                          index: index,
                          isSelected: isSelected,
                          selectedColor: selectedItemColor,
                          unselectedColor: unselectedItemColor,
                        );
                      }).toList(),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: tabs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tab = entry.value;
                      final isSelected = index == currentIndex;
                      
                      return Expanded(
                        child: _buildTabItem(
                          tab: tab,
                          index: index,
                          isSelected: isSelected,
                          selectedColor: selectedItemColor,
                          unselectedColor: unselectedItemColor,
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required LiquidNavigationBarItem tab,
    required int index,
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.md,
          vertical: DesignTokens.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          color: isSelected 
              ? selectedColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.xs),
            Text(
              tab.label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
