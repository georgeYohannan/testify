import 'package:flutter/material.dart';
import 'package:testify/models/verse.dart';
import 'package:testify/services/quiz_service.dart';
import 'package:testify/widgets/elephant_mascot.dart';
import 'package:testify/widgets/verse_card.dart';
import 'package:testify/screens/auth_screen.dart';
import 'package:testify/screens/dashboard_screen.dart';
import 'package:testify/supabase/supabase_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Verse? _dailyVerse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDailyVerse();
    _checkAuthState();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  void _loadDailyVerse() async {
    try {
      final verse = await QuizService.getDailyVerse();
      if (mounted) {
        setState(() {
          _dailyVerse = verse;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _checkAuthState() {
    SupabaseAuth.authStream.listen((state) {
      if (mounted && state.event.name == 'signedIn') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const Spacer(),
                        // App Title and Mascot
                        const ElephantMascot(
                          state: ElephantState.encouraging,
                          size: 150,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Testify',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Test your Bible knowledge with joy! 📖✨',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const Spacer(),
                        
                        // Daily Verse
                        if (_dailyVerse != null)
                          VerseCard(verse: _dailyVerse!)
                        else if (_isLoading)
                          const CircularProgressIndicator(),
                        
                        const Spacer(),
                        
                        // Action Buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => _navigateToAuth(isSignUp: true),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Sign Up'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _navigateToAuth(isSignUp: false),
                                icon: const Icon(Icons.login),
                                label: const Text('Login'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAuth({required bool isSignUp}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthScreen(initialIsSignUp: isSignUp),
      ),
    );
  }
}