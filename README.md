# Testify - Bible Quiz App 🐘📖

A modern, responsive Bible quiz app built with **Dreamflow** - the next generation of visual Flutter development.

## 🚀 **Built with Dreamflow**

This app is entirely built using **Dreamflow**, providing:
- ✅ **Visual Development** - Drag & drop interface with AI assistance
- ✅ **Modern UI Components** - Latest Flutter widgets and patterns
- ✅ **Advanced Responsive Design** - Perfect on all screen sizes
- ✅ **Supabase Integration** - Seamless backend connection
- ✅ **Production Ready** - Clean, optimized Flutter code

## 🎯 **Features**

- **Interactive Bible Quizzes**: Multiple-choice questions with difficulty levels
- **Daily Inspiration**: Random verse of the day
- **Progress Tracking**: Quiz history and performance analytics
- **Animated Mascot**: Cheerful elephant that reacts to user answers
- **Responsive Design**: Works perfectly on mobile, tablet, and desktop
- **Modern Authentication**: Secure user management with Supabase

## 🏗️ **Architecture**

- **Frontend**: Flutter (built with Dreamflow)
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **Database**: Structured tables for users, questions, verses, and quiz history
- **Deployment**: Cross-platform (iOS, Android, Web)

## 📱 **Platform Support**

- ✅ **iOS** - Native iOS app
- ✅ **Android** - Native Android app  
- ✅ **Web** - Progressive Web App (PWA)
- ✅ **Responsive** - Adapts to all screen sizes

## 🛠️ **Tech Stack**

- **Frontend**: Flutter (Dreamflow-generated)
- **Backend**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth
- **State Management**: Provider/Riverpod
- **Navigation**: GoRouter

## 📋 **Prerequisites**

- Flutter SDK (latest stable)
- Supabase account
- Git

## 🚀 **Quick Start**

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

### 4. Web Development
```bash
cd mobile
flutter config --enable-web
flutter run -d web-server
```

## 📊 **Database Schema**

### Tables
- **users**: User authentication and profiles
- **questions**: Quiz questions with difficulty levels
- **verses**: Biblical verses for daily inspiration
- **quiz_history**: User quiz performance tracking

## 🎨 **Design System**

- **Colors**: Sky blue, orange, white
- **Mascot**: Blue elephant holding an open Bible
- **Fonts**: Modern, accessible typography
- **Animations**: Smooth transitions and mascot reactions
- **Responsive**: Mobile-first design that scales to desktop

## 🔄 **Development Workflow**

### **Dreamflow Development**
1. **Build in Dreamflow** - Use visual interface and AI assistance
2. **Test and iterate** - Rapid prototyping and refinement
3. **Export code** - Download production-ready Flutter code
4. **Deploy** - Build and publish to all platforms

### **Local Development**
1. **Customize code** - Add custom features and optimizations
2. **Test thoroughly** - Multiple platforms and screen sizes
3. **Deploy updates** - Continuous development and refinement

## 🚀 **Deployment**

### **Mobile Apps**
```bash
# Build Android APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

### **Web App**
```bash
# Build optimized web version
flutter build web --release --web-renderer canvaskit

# Deploy build/web folder to web hosting
```

## 🛠️ **Best Practices**

### **Code Organization**
- Keep Dreamflow-generated code organized
- Add custom code in separate, well-structured files
- Maintain clean separation of concerns
- Follow Flutter best practices

### **Performance Optimization**
- Lazy load images and assets
- Optimize database queries and caching
- Use efficient state management
- Minimize widget rebuilds
- Implement proper error boundaries

## 🔍 **Troubleshooting**

### **Common Issues**
- **Dependencies**: Run `flutter clean && flutter pub get`
- **Build errors**: Check Flutter version compatibility
- **Responsive issues**: Test on different screen sizes
- **Supabase connection**: Verify API keys and configuration

### **Getting Help**
- Dreamflow documentation and tutorials
- Flutter documentation and community
- Supabase documentation and support
- Community forums and Stack Overflow

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 **Acknowledgments**

- NAB Bible content
- Flutter and Dreamflow communities
- Supabase team for the amazing backend platform

---

**Made with ❤️ and Dreamflow for spreading joy and knowledge through Bible study! 🐘✨🚀**
