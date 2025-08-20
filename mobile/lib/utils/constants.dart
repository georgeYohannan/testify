import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF4A90E2); // Sky blue
  static const Color secondaryLight = Color(0xFFFF6B35); // Orange
  static const Color accentLight = Color(0xFFF5A623); // Light orange
  static const Color backgroundLight = Color(0xFFFAFAFA); // Light background
  static const Color surfaceLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textSecondaryLight = Color(0xFF7F8C8D);
  
  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF4A90E2); // Sky blue (same)
  static const Color secondaryDark = Color(0xFFFF6B35); // Orange (same)
  static const Color accentDark = Color(0xFFF5A623); // Light orange (same)
  static const Color backgroundDark = Color(0xFF121212); // Dark background
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark surface
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White text
  static const Color textSecondaryDark = Color(0xFFB0B0B0); // Light gray text
  
  // Status Colors (same for both themes)
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  
  // Legacy colors for backwards compatibility
  static const Color primary = primaryLight;
  static const Color secondary = secondaryLight;
  static const Color accent = accentLight;
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
}

class AppTextStyles {
  // Light theme text styles
  static const TextStyle heading1Light = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryLight,
  );
  
  static const TextStyle heading2Light = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );
  
  static const TextStyle heading3Light = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryLight,
  );
  
  static const TextStyle body1Light = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryLight,
  );
  
  static const TextStyle body2Light = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryLight,
  );
  
  // Dark theme text styles
  static const TextStyle heading1Dark = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
  );
  
  static const TextStyle heading2Dark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );
  
  static const TextStyle heading3Dark = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );
  
  static const TextStyle body1Dark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryDark,
  );
  
  static const TextStyle body2Dark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryDark,
  );
  
  // Common styles (theme-independent)
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  // Legacy styles for backwards compatibility
  static const TextStyle heading1 = heading1Light;
  static const TextStyle heading2 = heading2Light;
  static const TextStyle heading3 = heading3Light;
  static const TextStyle body1 = body1Light;
  static const TextStyle body2 = body2Light;
}

class AppSizes {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;
  
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
}

class AppStrings {
  static const String appName = 'Testify';
  static const String appTagline = 'Joyful Bible Learning';
  static const String welcomeMessage = 'Welcome to Testify!';
  static const String dailyVerse = 'Verse of the Day';
  static const String startQuiz = 'Start Quiz';
  static const String quizHistory = 'Quiz History';
  static const String settings = 'Settings';
  static const String logout = 'Logout';
  
  // Quiz related
  static const String selectBook = 'Select a Book';
  static const String selectDifficulty = 'Select Difficulty';
  static const String easy = 'Easy';
  static const String medium = 'Medium';
  static const String hard = 'Hard';
  static const String question = 'Question';
  static const String correct = 'Correct!';
  static const String incorrect = 'Incorrect';
  static const String next = 'Next';
  static const String finish = 'Finish';
  static const String quizComplete = 'Quiz Complete!';
  static const String yourScore = 'Your Score';
  static const String tryAgain = 'Try Again';
  static const String backToDashboard = 'Back to Dashboard';
  
  // Auth related
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  
  // Mascot messages
  static const String mascotWelcome = 'Hi there! I\'m Ellie, your Bible quiz companion!';
  static const String mascotCorrect = 'Great job! That\'s correct!';
  static const String mascotIncorrect = 'Oops! Let\'s try again!';
  static const String mascotEncouragement = 'You\'re doing amazing! Keep going!';
  static const String mascotCelebration = 'Fantastic! You completed the quiz!';
  
  // Bible books (abbreviated list)
  static const List<String> bibleBooks = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
    'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
    '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles',
    'Ezra', 'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
    'Ecclesiastes', 'Song of Songs', 'Isaiah', 'Jeremiah',
    'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel',
    'Amos', 'Obadiah', 'Jonah', 'Micah', 'Nahum',
    'Habakkuk', 'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
    'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians',
    'Ephesians', 'Philippians', 'Colossians', '1 Thessalonians',
    '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus',
    'Philemon', 'Hebrews', 'James', '1 Peter', '2 Peter',
    '1 John', '2 John', '3 John', 'Jude', 'Revelation'
  ];
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;
}
