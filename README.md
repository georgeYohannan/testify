# Testify - Bible Quiz App 🐘📖

A joyful Bible quiz app designed for all ages, featuring an animated elephant mascot and comprehensive quiz content.

## 🚀 Features

- **Interactive Bible Quizzes**: Multiple-choice questions from NAB-based content
- **Difficulty Levels**: Easy, Medium, and Hard challenges
- **Daily Inspiration**: Random verse of the day
- **Progress Tracking**: Quiz history and performance analytics
- **Animated Mascot**: Cheerful elephant that reacts to user answers
- **Content Management**: Direct database management through Supabase dashboard

## 🏗️ Architecture

- **Mobile App**: Flutter (iOS/Android)
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **Database**: Structured tables for users, questions, verses, and quiz history

## 📱 Mobile App Features

- Splash screen with elephant mascot
- User authentication (Supabase)
- Dashboard with daily verse and quiz history
- Quiz setup and execution
- Results with answer review
- Smooth animations and transitions



## 🛠️ Tech Stack

- **Frontend**: Flutter
- **Backend**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth
- **Deployment**: Supabase Hosting

## 📋 Prerequisites

- Flutter SDK (latest stable)
- Node.js (v18+)
- Supabase account
- Git

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd testify
```

### 2. Backend Setup
```bash
cd backend
# Follow Supabase setup instructions
```

### 3. Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

### 4. Content Management
Access the Supabase dashboard to manage questions, verses, and user data directly through the database interface.



## 📊 Database Schema

### Tables
- **users**: User authentication and profiles
- **questions**: Quiz questions with difficulty levels
- **verses**: Biblical verses for daily inspiration
- **quiz_history**: User quiz performance tracking

## 🎨 Design System

- **Colors**: Sky blue, orange, white
- **Mascot**: Blue elephant holding an open Bible
- **Fonts**: Rounded, accessible typography
- **Animations**: Smooth transitions and mascot reactions

## 📱 Platform Support

- ✅ iOS
- ✅ Android

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- NAB Bible content
- Flutter and React communities
- Supabase team for the amazing backend platform

---

Made with ❤️ for spreading joy and knowledge through Bible study!
