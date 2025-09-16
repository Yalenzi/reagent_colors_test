module.exports = {
  i18n: {
    defaultLocale: 'ar',
    locales: ['ar', 'en'],
    localeDetection: true,
  },
  
  // Namespace configuration
  ns: [
    'common',
    'auth',
    'dashboard',
    'tests',
    'results',
    'admin',
    'errors',
    'validation',
    'navigation',
    'forms'
  ],
  
  defaultNS: 'common',
  
  // Fallback language
  fallbackLng: {
    'ar-SA': ['ar'],
    'en-US': ['en'],
    default: ['ar']
  },
  
  // Debug mode
  debug: process.env.NODE_ENV === 'development',
  
  // Interpolation
  interpolation: {
    escapeValue: false,
  },
  
  // React options
  react: {
    useSuspense: false,
  },
  
  // Server-side options
  serverLanguageDetection: true,
  
  // Custom detection order
  detection: {
    order: ['path', 'header', 'cookie', 'localStorage', 'subdomain'],
    caches: ['cookie'],
  },
  
  // Resource loading
  load: 'languageOnly',
  
  // Preload languages
  preload: ['ar', 'en'],
  
  // Clean code
  cleanCode: true,
  
  // Lowercase
  lowerCaseLng: true,
  
  // Non-explicit support
  nonExplicitSupportedLngs: true,
};
