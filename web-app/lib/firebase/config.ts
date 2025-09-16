import { initializeApp, getApps, FirebaseApp } from 'firebase/app';
import { getAuth, Auth } from 'firebase/auth';
import { getFirestore, Firestore } from 'firebase/firestore';
import { getStorage, FirebaseStorage } from 'firebase/storage';
import { getAnalytics, Analytics } from 'firebase/analytics';

// Firebase configuration
const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  measurementId: process.env.NEXT_PUBLIC_FIREBASE_MEASUREMENT_ID,
};

// Initialize Firebase
let app: FirebaseApp;
if (getApps().length === 0) {
  app = initializeApp(firebaseConfig);
} else {
  app = getApps()[0];
}

// Initialize Firebase services
export const auth: Auth = getAuth(app);
export const db: Firestore = getFirestore(app);
export const storage: FirebaseStorage = getStorage(app);

// Initialize Analytics (only on client side)
export let analytics: Analytics | null = null;
if (typeof window !== 'undefined') {
  analytics = getAnalytics(app);
}

// Export the app
export default app;

// Firebase Admin SDK configuration (server-side only)
export const adminConfig = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
};

// Collection names
export const COLLECTIONS = {
  USERS: 'users',
  TESTS: 'tests',
  REAGENTS: 'reagents',
  TEST_RESULTS: 'testResults',
  CATEGORIES: 'categories',
  ANALYTICS: 'analytics',
  NOTIFICATIONS: 'notifications',
  SETTINGS: 'settings',
} as const;

// Storage paths
export const STORAGE_PATHS = {
  AVATARS: 'avatars',
  TEST_IMAGES: 'test-images',
  RESULT_IMAGES: 'result-images',
  REAGENT_IMAGES: 'reagent-images',
  DOCUMENTS: 'documents',
} as const;

// Firebase Auth providers
export const AUTH_PROVIDERS = {
  EMAIL: 'password',
  GOOGLE: 'google.com',
  GITHUB: 'github.com',
} as const;

// Firestore settings
export const FIRESTORE_SETTINGS = {
  cacheSizeBytes: 40 * 1024 * 1024, // 40 MB
  experimentalForceLongPolling: false,
  merge: true,
};

// Real-time listeners cleanup
export const cleanupListeners: (() => void)[] = [];

// Helper function to add cleanup listener
export const addCleanupListener = (cleanup: () => void) => {
  cleanupListeners.push(cleanup);
};

// Helper function to cleanup all listeners
export const cleanupAllListeners = () => {
  cleanupListeners.forEach(cleanup => cleanup());
  cleanupListeners.length = 0;
};

// Error codes mapping
export const FIREBASE_ERROR_CODES = {
  // Auth errors
  'auth/user-not-found': 'User not found',
  'auth/wrong-password': 'Invalid password',
  'auth/email-already-in-use': 'Email already in use',
  'auth/weak-password': 'Password is too weak',
  'auth/invalid-email': 'Invalid email address',
  'auth/user-disabled': 'User account is disabled',
  'auth/too-many-requests': 'Too many requests. Try again later',
  'auth/network-request-failed': 'Network error. Check your connection',
  
  // Firestore errors
  'firestore/permission-denied': 'Permission denied',
  'firestore/not-found': 'Document not found',
  'firestore/already-exists': 'Document already exists',
  'firestore/resource-exhausted': 'Quota exceeded',
  'firestore/failed-precondition': 'Operation failed',
  'firestore/aborted': 'Operation aborted',
  'firestore/out-of-range': 'Invalid range',
  'firestore/unimplemented': 'Operation not implemented',
  'firestore/internal': 'Internal error',
  'firestore/unavailable': 'Service unavailable',
  'firestore/data-loss': 'Data loss',
  'firestore/unauthenticated': 'User not authenticated',
  
  // Storage errors
  'storage/object-not-found': 'File not found',
  'storage/bucket-not-found': 'Bucket not found',
  'storage/project-not-found': 'Project not found',
  'storage/quota-exceeded': 'Storage quota exceeded',
  'storage/unauthenticated': 'User not authenticated',
  'storage/unauthorized': 'User not authorized',
  'storage/retry-limit-exceeded': 'Retry limit exceeded',
  'storage/invalid-checksum': 'Invalid file checksum',
  'storage/canceled': 'Operation canceled',
  'storage/invalid-event-name': 'Invalid event name',
  'storage/invalid-url': 'Invalid URL',
  'storage/invalid-argument': 'Invalid argument',
  'storage/no-default-bucket': 'No default bucket',
  'storage/cannot-slice-blob': 'Cannot slice blob',
  'storage/server-file-wrong-size': 'Server file wrong size',
} as const;

// Helper function to get user-friendly error message
export const getFirebaseErrorMessage = (errorCode: string): string => {
  return FIREBASE_ERROR_CODES[errorCode as keyof typeof FIREBASE_ERROR_CODES] || 'An unexpected error occurred';
};

// Environment validation
const requiredEnvVars = [
  'NEXT_PUBLIC_FIREBASE_API_KEY',
  'NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN',
  'NEXT_PUBLIC_FIREBASE_PROJECT_ID',
  'NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET',
  'NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID',
  'NEXT_PUBLIC_FIREBASE_APP_ID',
];

const missingEnvVars = requiredEnvVars.filter(envVar => !process.env[envVar]);

if (missingEnvVars.length > 0) {
  console.error('Missing required environment variables:', missingEnvVars);
  if (process.env.NODE_ENV === 'production') {
    throw new Error(`Missing required environment variables: ${missingEnvVars.join(', ')}`);
  }
}

// Development mode warnings
if (process.env.NODE_ENV === 'development') {
  console.log('🔥 Firebase initialized in development mode');
  console.log('📊 Project ID:', firebaseConfig.projectId);
}

export { firebaseConfig };
