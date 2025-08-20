import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class ThemeToggle extends StatelessWidget {
  final bool showLabel;
  final MainAxisAlignment alignment;

  const ThemeToggle({
    super.key,
    this.showLabel = true,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Icon(
                Icons.light_mode,
                color: !themeProvider.isDarkMode 
                    ? AppColors.primaryLight 
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: () {
                themeProvider.toggleTheme();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: themeProvider.isDarkMode 
                      ? AppColors.primaryLight 
                      : Colors.grey[300],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: themeProvider.isDarkMode ? 32 : 2,
                      top: 2,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          themeProvider.isDarkMode 
                              ? Icons.dark_mode 
                              : Icons.light_mode,
                          size: 16,
                          color: themeProvider.isDarkMode 
                              ? AppColors.primaryLight 
                              : AppColors.secondaryLight,
                        ),
                      ).animate().scale(
                        duration: 200.ms,
                        curve: Curves.elasticOut,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.dark_mode,
                color: themeProvider.isDarkMode 
                    ? AppColors.primaryLight 
                    : Colors.grey,
                size: 20,
              ),
            ],
          ],
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          onPressed: () {
            themeProvider.toggleTheme();
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(themeProvider.isDarkMode),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          tooltip: themeProvider.isDarkMode ? AppStrings.lightMode : AppStrings.darkMode,
        ).animate().scale(
          duration: 200.ms,
          curve: Curves.elasticOut,
        );
      },
    );
  }
}
