import 'package:go_router/go_router.dart';
import 'package:testify/screens/splash_screen.dart';
import 'package:testify/screens/auth_screen.dart';
import 'package:testify/screens/dashboard_screen.dart';
import 'package:testify/screens/quiz_setup_screen.dart';
import 'package:testify/screens/quiz_screen.dart';
import 'package:testify/screens/results_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) {
        final isSignUp = state.uri.queryParameters['mode'] == 'signup';
        return AuthScreen(initialIsSignUp: isSignUp);
      },
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/quiz-setup',
      name: 'quiz-setup',
      builder: (context, state) => const QuizSetupScreen(),
    ),
    GoRoute(
      path: '/quiz',
      name: 'quiz',
      builder: (context, state) {
        final quizId = state.uri.queryParameters['id'];
        final difficulty = state.uri.queryParameters['difficulty'];
        return QuizScreen(
          quizId: quizId ?? '',
          difficulty: difficulty ?? 'medium',
        );
      },
    ),
    GoRoute(
      path: '/results',
      name: 'results',
      builder: (context, state) {
        final score = int.tryParse(state.uri.queryParameters['score'] ?? '0') ?? 0;
        final total = int.tryParse(state.uri.queryParameters['total'] ?? '0') ?? 0;
        final time = int.tryParse(state.uri.queryParameters['time'] ?? '0') ?? 0;
        return ResultsScreen(
          score: score,
          totalQuestions: total,
          timeInSeconds: time,
        );
      },
    ),
  ],
);
