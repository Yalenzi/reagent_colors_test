# 🗄️ هيكل قاعدة البيانات المتقدم - ColorTests Web App

## 📊 Collections Structure

### 1. Users Collection (`users`)
```typescript
interface User {
  id: string;                    // Firebase Auth UID
  email: string;
  username: string;
  displayName: string;
  role: 'admin' | 'user' | 'moderator';
  avatar?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastLoginAt: Timestamp;
  isActive: boolean;
  preferences: {
    language: 'ar' | 'en';
    theme: 'light' | 'dark';
    notifications: boolean;
  };
  profile: {
    organization?: string;
    position?: string;
    phone?: string;
    country?: string;
  };
}
```

### 2. Tests Collection (`tests`)
```typescript
interface Test {
  id: string;
  name: {
    ar: string;
    en: string;
  };
  description: {
    ar: string;
    en: string;
  };
  category: string;
  reagents: Reagent[];
  expectedResults: TestResult[];
  instructions: {
    ar: string[];
    en: string[];
  };
  safetyNotes: {
    ar: string[];
    en: string[];
  };
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  estimatedTime: number;        // in minutes
  isActive: boolean;
  createdBy: string;           // User ID
  createdAt: Timestamp;
  updatedAt: Timestamp;
  version: number;
  tags: string[];
  images?: string[];           // URLs to test images
  videos?: string[];           // URLs to instructional videos
}
```

### 3. Reagents Collection (`reagents`)
```typescript
interface Reagent {
  id: string;
  name: {
    ar: string;
    en: string;
  };
  chemicalFormula: string;
  description: {
    ar: string;
    en: string;
  };
  safetyLevel: 'low' | 'medium' | 'high' | 'extreme';
  safetyInstructions: {
    ar: string[];
    en: string[];
  };
  storageConditions: {
    ar: string;
    en: string;
  };
  expiryMonths: number;
  supplier?: string;
  cost?: number;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 4. Test Results Collection (`testResults`)
```typescript
interface TestResult {
  id: string;
  testId: string;
  userId: string;
  sampleName: string;
  results: {
    reagentId: string;
    observedColor: string;
    expectedColor: string;
    match: boolean;
    confidence: number;        // 0-100
    notes?: string;
    image?: string;           // URL to result image
  }[];
  conclusion: {
    substance?: string;
    confidence: number;
    notes: string;
  };
  metadata: {
    testDate: Timestamp;
    duration: number;         // in minutes
    temperature?: number;
    humidity?: number;
    location?: string;
  };
  isVerified: boolean;
  verifiedBy?: string;       // Admin/Moderator ID
  verifiedAt?: Timestamp;
  createdAt: Timestamp;
}
```

### 5. Categories Collection (`categories`)
```typescript
interface Category {
  id: string;
  name: {
    ar: string;
    en: string;
  };
  description: {
    ar: string;
    en: string;
  };
  icon: string;
  color: string;
  order: number;
  isActive: boolean;
  testsCount: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 6. Analytics Collection (`analytics`)
```typescript
interface Analytics {
  id: string;
  type: 'test_performed' | 'user_login' | 'page_view' | 'error';
  userId?: string;
  testId?: string;
  data: Record<string, any>;
  timestamp: Timestamp;
  sessionId: string;
  userAgent?: string;
  ipAddress?: string;
  country?: string;
}
```

### 7. Notifications Collection (`notifications`)
```typescript
interface Notification {
  id: string;
  userId: string;
  type: 'info' | 'warning' | 'success' | 'error';
  title: {
    ar: string;
    en: string;
  };
  message: {
    ar: string;
    en: string;
  };
  isRead: boolean;
  actionUrl?: string;
  createdAt: Timestamp;
  expiresAt?: Timestamp;
}
```

### 8. System Settings Collection (`settings`)
```typescript
interface SystemSettings {
  id: string;
  key: string;
  value: any;
  description: {
    ar: string;
    en: string;
  };
  type: 'string' | 'number' | 'boolean' | 'object';
  isPublic: boolean;
  updatedBy: string;
  updatedAt: Timestamp;
}
```

## 🔐 Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && isAdmin();
      allow create: if request.auth != null;
    }
    
    // Tests collection
    match /tests/{testId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (isAdmin() || isModerator());
    }
    
    // Test Results collection
    match /testResults/{resultId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || isAdmin() || isModerator());
      allow create: if request.auth != null;
    }
    
    // Admin-only collections
    match /analytics/{docId} {
      allow read, write: if isAdmin();
    }
    
    match /settings/{docId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
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

## 📈 Indexes Required

### Composite Indexes
```javascript
// For test results filtering
{
  collection: "testResults",
  fields: [
    { field: "userId", order: "ASCENDING" },
    { field: "createdAt", order: "DESCENDING" }
  ]
}

// For analytics queries
{
  collection: "analytics",
  fields: [
    { field: "type", order: "ASCENDING" },
    { field: "timestamp", order: "DESCENDING" }
  ]
}

// For active tests by category
{
  collection: "tests",
  fields: [
    { field: "isActive", order: "ASCENDING" },
    { field: "category", order: "ASCENDING" },
    { field: "createdAt", order: "DESCENDING" }
  ]
}
```

## 🔄 Data Synchronization

### Real-time Updates
- **Tests**: تحديث فوري عند إضافة/تعديل الاختبارات
- **Results**: مزامنة النتائج بين الويب والموبايل
- **Notifications**: إشعارات فورية للمستخدمين
- **Analytics**: تتبع الاستخدام في الوقت الفعلي

### Offline Support
- **Cache Strategy**: تخزين البيانات المهمة محلياً
- **Sync Queue**: قائمة انتظار للتحديثات عند عودة الاتصال
- **Conflict Resolution**: حل تضارب البيانات تلقائياً
