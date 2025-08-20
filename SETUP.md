# Testify Setup Guide 🚀

This guide will walk you through setting up the complete Testify Bible Quiz App, including the Flutter mobile app and Supabase backend.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (latest stable version)

- **Git**
- **Supabase CLI** (optional, for local development)
- **Android Studio** or **Xcode** (for mobile development)

## 🏗️ Project Structure

```
testify/
├── backend/                 # Supabase backend
│   └── supabase/
│       ├── config.toml     # Supabase configuration
│       └── migrations/     # Database migrations
├── mobile/                 # Flutter mobile app
│   ├── lib/
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management
│   │   ├── screens/        # UI screens
│   │   └── utils/          # Utilities and constants
│   └── pubspec.yaml        # Flutter dependencies

└── README.md               # Project overview
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd testify
```

### 2. Backend Setup (Supabase)

#### Option A: Use Supabase Cloud (Recommended)

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Copy your project URL and anon key from the project settings
3. Update the configuration files:

**Flutter App (`mobile/lib/main.dart`):**
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Replace with your URL
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // Replace with your anon key
);
```



4. Run the database migration:
   - Go to your Supabase project dashboard
   - Navigate to SQL Editor
   - Copy and paste the contents of `backend/supabase/migrations/001_initial_schema.sql`
   - Execute the SQL

#### Option B: Local Supabase Development

1. Install Supabase CLI:
```bash
npm install -g supabase
```

2. Start local Supabase:
```bash
cd backend
supabase start
```

3. Apply migrations:
```bash
supabase db reset
```

### 3. Mobile App Setup

1. Navigate to the mobile directory:
```bash
cd mobile
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Update Supabase configuration in `lib/main.dart`

4. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run -d ios
```



## 🔐 Authentication Setup



### User Registration

Regular users can sign up through the mobile app. Their accounts will be automatically created in the `users` table.

## 📊 Content Management

### Supabase Dashboard

All content management is done directly through the Supabase dashboard:

1. **Questions Management:**
   - Navigate to Table Editor > questions
   - Add, edit, or delete quiz questions
   - Bulk import data using CSV upload

2. **Verses Management:**
   - Navigate to Table Editor > verses
   - Manage daily inspirational verses
   - Update verse content and references

3. **User Management:**
   - Monitor user accounts in Authentication > Users
   - View user profiles and quiz history
   - Manage user data and permissions

4. **Database Policies:**
   - Configure Row Level Security (RLS) policies
   - Set up appropriate access controls
   - Monitor database performance and logs

## 📱 Mobile App Features

### Screens
- **Splash Screen**: App introduction with elephant mascot
- **Authentication**: Login/signup with Supabase
- **Dashboard**: Daily verse, quiz history, and quick actions
- **Quiz Setup**: Select book and difficulty
- **Quiz**: Interactive question answering with mascot feedback
- **Results**: Score summary and answer review

### Key Components
- **AuthProvider**: Manages user authentication state
- **QuizProvider**: Handles quiz logic and state
- **VerseProvider**: Manages daily verses
- **Custom UI**: Beautiful, accessible design with animations



## 🗄️ Database Schema

### Tables

#### `users`
- User profiles and authentication data
- RLS policies ensure users only see their own data

#### `questions`
- Quiz questions with difficulty levels
- Options stored as arrays
- Verse references for context

#### `verses`
- Daily inspirational verses
- Used for verse of the day feature

#### `quiz_history`
- User quiz performance tracking
- Detailed answer analysis
- Performance metrics and grades

## 🎨 Customization

### Colors and Themes

**Mobile App:**
- Edit `mobile/lib/utils/constants.dart`
- Modify `AppColors` class for brand colors



### Mascot and Branding

- Replace elephant icon with custom mascot
- Update app icons and splash screen
- Modify welcome messages and copy

## 🚀 Deployment

### Mobile App
- **Android**: Build APK or upload to Google Play Store
- **iOS**: Archive and upload to App Store Connect
- **Web**: Run `flutter build web` for web deployment



### Backend
- **Supabase Cloud**: Production-ready hosted solution
- **Self-hosted**: Deploy Supabase to your infrastructure

## 🧪 Testing

### Mobile App
```bash
cd mobile
flutter test
```



## 📊 Monitoring and Analytics

- **Supabase Dashboard**: Monitor database performance
- **User Analytics**: Track quiz completion rates
- **Error Logging**: Monitor app crashes and issues

## 🔧 Troubleshooting

### Common Issues

1. **Supabase Connection Errors**
   - Verify URL and API keys
   - Check network connectivity
   - Ensure RLS policies are correct

2. **Flutter Build Issues**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter version compatibility
   - Verify Android/iOS setup



### Getting Help

- Check the [Flutter documentation](https://flutter.dev/docs)
- Visit [Supabase docs](https://supabase.com/docs)
- Review [React documentation](https://reactjs.org/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- **Flutter Team**: Amazing cross-platform framework
- **Supabase**: Powerful backend-as-a-service

- **Bible Content**: NAB-based quiz material

---

**Happy coding! 🎉**

If you encounter any issues or have questions, please check the troubleshooting section or create an issue in the repository.
