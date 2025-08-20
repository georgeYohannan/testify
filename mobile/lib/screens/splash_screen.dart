import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/verse_provider.dart';
import '../utils/constants.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _elephantController;
  late AnimationController _textController;
  late AnimationController _verseController;

  @override
  void initState() {
    super.initState();
    
    _elephantController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _verseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _startAnimations();
    _navigateAfterDelay();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _elephantController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _textController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      _verseController.forward();
    });
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 4));
    
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _elephantController.dispose();
    _textController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Elephant Mascot
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pets,
                  size: 120,
                  color: AppColors.primary,
                ),
              )
                  .animate(controller: _elephantController)
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: const Duration(seconds: 2)),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // App Title
              Text(
                AppStrings.appName,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate(controller: _textController)
                  .fadeIn(duration: const Duration(milliseconds: 800))
                  .slideY(begin: 0.3, end: 0.0),
              
              Text(
                AppStrings.appTagline,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              )
                  .animate(controller: _textController)
                  .fadeIn(delay: const Duration(milliseconds: 200))
                  .slideY(begin: 0.3, end: 0.0),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Daily Verse
              Consumer<VerseProvider>(
                builder: (context, verseProvider, child) {
                  if (verseProvider.isLoading) {
                    return const CircularProgressIndicator(
                      color: AppColors.primary,
                    );
                  }
                  
                  final dailyVerse = verseProvider.dailyVerse;
                  if (dailyVerse == null) {
                    return const SizedBox.shrink();
                  }
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.dailyVerse,
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          dailyVerse.text,
                          style: AppTextStyles.body1.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          dailyVerse.reference,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _verseController)
                      .fadeIn(duration: const Duration(milliseconds: 800))
                      .slideY(begin: 0.3, end: 0.0);
                },
              ),
              
              const SizedBox(height: AppSizes.paddingXL),
              
              // Loading indicator
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: const Duration(seconds: 1)),
            ],
          ),
        ),
      ),
    );
  }
}
