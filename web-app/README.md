# 🧪 ColorTests - Advanced Color Testing System

[![Next.js](https://img.shields.io/badge/Next.js-14-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-blue)](https://www.typescriptlang.org/)
[![Firebase](https://img.shields.io/badge/Firebase-10-orange)](https://firebase.google.com/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-3-cyan)](https://tailwindcss.com/)
[![Netlify](https://img.shields.io/badge/Netlify-Deploy-green)](https://netlify.com/)

A comprehensive web application for scientific color testing and chemical analysis, featuring real-time synchronization with mobile apps and advanced admin dashboard.

## 🌟 Features

### 🔐 Authentication & Authorization
- **Multi-provider Authentication** (Email/Password, Google)
- **Role-based Access Control** (Admin, Moderator, User)
- **Secure Session Management**
- **Password Reset & Email Verification**

### 🧪 Test Management
- **Real-time Test Creation & Editing**
- **Multi-language Support** (Arabic/English)
- **Rich Media Upload** (Images, Videos)
- **Reagent Management**
- **Safety Instructions**
- **Difficulty Levels**

### 📊 Admin Dashboard
- **Comprehensive Analytics**
- **User Management**
- **Test Results Monitoring**
- **Real-time Notifications**
- **System Settings**

### 🔄 Real-time Synchronization
- **Instant Updates** across all platforms
- **Mobile App Integration**
- **Cloud Functions** for automated processes
- **Push Notifications**

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- npm or yarn
- Firebase CLI
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/colorstest/web-app.git
cd web-app
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment variables**
```bash
cp .env.example .env.local
```

4. **Configure Firebase**
```bash
firebase login
firebase init
```

5. **Start development server**
```bash
npm run dev
```

Visit `http://localhost:3000` to see the application.

## 🏗️ Project Structure

```
web-app/
├── components/           # React components
│   ├── admin/           # Admin dashboard components
│   ├── common/          # Shared components
│   └── layouts/         # Page layouts
├── pages/               # Next.js pages
│   ├── admin/           # Admin pages
│   ├── auth/            # Authentication pages
│   └── api/             # API routes
├── hooks/               # Custom React hooks
├── lib/                 # Libraries and utilities
│   ├── firebase/        # Firebase configuration
│   └── utils/           # Helper functions
├── types/               # TypeScript definitions
├── styles/              # CSS files
├── public/              # Static assets
└── functions/           # Firebase Cloud Functions
```

## 🔧 Configuration

### Environment Variables

Create a `.env.local` file with the following variables:

```env
# Firebase Configuration
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_auth_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_storage_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID=your_measurement_id

# Firebase Admin (Server-side)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
```

### Firebase Setup

1. **Create a Firebase project**
2. **Enable Authentication** (Email/Password, Google)
3. **Set up Firestore Database**
4. **Configure Storage**
5. **Deploy Security Rules**

## 📱 Mobile App Integration

This web application is designed to work seamlessly with the Flutter mobile app:

- **Real-time Data Sync** via Firestore
- **Shared Authentication** system
- **Unified User Management**
- **Cross-platform Notifications**

## 🚀 Deployment

### Netlify Deployment

1. **Connect your repository** to Netlify
2. **Set build command**: `npm run build && npm run export`
3. **Set publish directory**: `out`
4. **Configure environment variables**
5. **Deploy**

### Firebase Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

## 🔒 Security

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == userId || isAdmin());
    }
    
    // Tests are readable by authenticated users
    match /tests/{testId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (isAdmin() || isModerator());
    }
    
    // Helper functions
    function isAdmin() {
      return request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isModerator() {
      return request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'moderator'];
    }
  }
}
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

## 📊 Analytics & Monitoring

- **Firebase Analytics** for user behavior tracking
- **Performance Monitoring** for app performance
- **Error Tracking** with detailed logging
- **Custom Events** for business metrics

## 🌐 Internationalization

The application supports multiple languages:

- **Arabic** (RTL support)
- **English** (LTR support)

Add new languages by:
1. Creating translation files in `public/locales/[lang]/`
2. Updating `next-i18next.config.js`
3. Adding language option to `LanguageSwitcher`

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Mohammed Nafa Al-Ruwaili** - *Lead Developer*
- **Youssef Musayyir Al-Anzi** - *Co-Developer*

## 🙏 Acknowledgments

- Firebase team for excellent backend services
- Next.js team for the amazing framework
- Tailwind CSS for beautiful styling
- The open-source community

## 📞 Support

- **Website**: https://colorstest.com/
- **Email**: support@colorstest.com
- **Documentation**: https://docs.colorstest.com/
- **Issues**: [GitHub Issues](https://github.com/colorstest/web-app/issues)

---

**ColorTests** - Advancing scientific analysis through innovative color testing technology.

*Built with ❤️ using Next.js, Firebase, and modern web technologies.*
