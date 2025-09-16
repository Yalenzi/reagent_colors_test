import { useState, useEffect, useCallback } from 'react';
import {
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  onSnapshot,
  query,
  where,
  orderBy,
  limit,
  startAfter,
  Timestamp,
  writeBatch,
} from 'firebase/firestore';
import { ref, uploadBytes, getDownloadURL, deleteObject } from 'firebase/storage';
import { toast } from 'react-hot-toast';

import { db, storage, COLLECTIONS, STORAGE_PATHS } from '../lib/firebase/config';
import { useAuth } from './useAuth';
import { Test, TestFormData, TestResult } from '../types/test';
import { logAnalytics } from '../lib/analytics';

interface UseTestsReturn {
  tests: Test[];
  loading: boolean;
  error: string | null;
  hasMore: boolean;
  createTest: (testData: TestFormData) => Promise<string>;
  updateTest: (testId: string, testData: Partial<TestFormData>) => Promise<void>;
  deleteTest: (testId: string) => Promise<void>;
  getTest: (testId: string) => Promise<Test | null>;
  loadMore: () => Promise<void>;
  refresh: () => Promise<void>;
  uploadTestImage: (file: File, testId: string) => Promise<string>;
  deleteTestImage: (imageUrl: string) => Promise<void>;
  toggleTestStatus: (testId: string, isActive: boolean) => Promise<void>;
  duplicateTest: (testId: string) => Promise<string>;
  bulkUpdateTests: (testIds: string[], updates: Partial<TestFormData>) => Promise<void>;
}

const TESTS_PER_PAGE = 20;

export const useTests = (filters?: {
  category?: string;
  isActive?: boolean;
  createdBy?: string;
}): UseTestsReturn => {
  const { user } = useAuth();
  const [tests, setTests] = useState<Test[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState(true);
  const [lastDoc, setLastDoc] = useState<any>(null);

  // Build query based on filters
  const buildQuery = useCallback((startAfterDoc?: any) => {
    let q = query(
      collection(db, COLLECTIONS.TESTS),
      orderBy('createdAt', 'desc')
    );

    if (filters?.category) {
      q = query(q, where('category', '==', filters.category));
    }

    if (filters?.isActive !== undefined) {
      q = query(q, where('isActive', '==', filters.isActive));
    }

    if (filters?.createdBy) {
      q = query(q, where('createdBy', '==', filters.createdBy));
    }

    q = query(q, limit(TESTS_PER_PAGE));

    if (startAfterDoc) {
      q = query(q, startAfter(startAfterDoc));
    }

    return q;
  }, [filters]);

  // Load tests with real-time updates
  const loadTests = useCallback(async (reset = false) => {
    try {
      setLoading(true);
      setError(null);

      const q = buildQuery(reset ? null : lastDoc);
      
      // Set up real-time listener
      const unsubscribe = onSnapshot(q, (snapshot) => {
        const newTests: Test[] = [];
        
        snapshot.forEach((doc) => {
          newTests.push({
            id: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toDate(),
            updatedAt: doc.data().updatedAt?.toDate(),
          } as Test);
        });

        if (reset) {
          setTests(newTests);
        } else {
          setTests(prev => [...prev, ...newTests]);
        }

        setHasMore(newTests.length === TESTS_PER_PAGE);
        setLastDoc(snapshot.docs[snapshot.docs.length - 1]);
        setLoading(false);
      }, (error) => {
        console.error('Error loading tests:', error);
        setError(error.message);
        setLoading(false);
      });

      return unsubscribe;
    } catch (error: any) {
      console.error('Error setting up tests listener:', error);
      setError(error.message);
      setLoading(false);
    }
  }, [buildQuery, lastDoc]);

  // Initialize tests loading
  useEffect(() => {
    const unsubscribe = loadTests(true);
    return () => {
      if (unsubscribe) {
        unsubscribe.then(unsub => unsub?.());
      }
    };
  }, [loadTests]);

  // Create new test
  const createTest = async (testData: TestFormData): Promise<string> => {
    if (!user) throw new Error('User not authenticated');

    try {
      const newTest = {
        ...testData,
        createdBy: user.uid,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        version: 1,
        isActive: true,
      };

      const docRef = await addDoc(collection(db, COLLECTIONS.TESTS), newTest);
      
      // Log analytics
      await logAnalytics('test_created', {
        testId: docRef.id,
        category: testData.category,
        difficulty: testData.difficulty,
      });

      return docRef.id;
    } catch (error: any) {
      console.error('Error creating test:', error);
      throw new Error(`Failed to create test: ${error.message}`);
    }
  };

  // Update existing test
  const updateTest = async (testId: string, testData: Partial<TestFormData>): Promise<void> => {
    if (!user) throw new Error('User not authenticated');

    try {
      const testRef = doc(db, COLLECTIONS.TESTS, testId);
      const testDoc = await getDoc(testRef);
      
      if (!testDoc.exists()) {
        throw new Error('Test not found');
      }

      const currentVersion = testDoc.data().version || 1;
      
      await updateDoc(testRef, {
        ...testData,
        updatedAt: Timestamp.now(),
        version: currentVersion + 1,
      });

      // Log analytics
      await logAnalytics('test_updated', {
        testId,
        updatedFields: Object.keys(testData),
      });
    } catch (error: any) {
      console.error('Error updating test:', error);
      throw new Error(`Failed to update test: ${error.message}`);
    }
  };

  // Delete test
  const deleteTest = async (testId: string): Promise<void> => {
    if (!user) throw new Error('User not authenticated');

    try {
      // Get test data first to clean up associated files
      const testDoc = await getDoc(doc(db, COLLECTIONS.TESTS, testId));
      if (!testDoc.exists()) {
        throw new Error('Test not found');
      }

      const testData = testDoc.data() as Test;

      // Delete associated images
      if (testData.images && testData.images.length > 0) {
        const deletePromises = testData.images.map(imageUrl => 
          deleteTestImage(imageUrl).catch(console.error)
        );
        await Promise.all(deletePromises);
      }

      // Delete the test document
      await deleteDoc(doc(db, COLLECTIONS.TESTS, testId));

      // Log analytics
      await logAnalytics('test_deleted', {
        testId,
        category: testData.category,
      });
    } catch (error: any) {
      console.error('Error deleting test:', error);
      throw new Error(`Failed to delete test: ${error.message}`);
    }
  };

  // Get single test
  const getTest = async (testId: string): Promise<Test | null> => {
    try {
      const testDoc = await getDoc(doc(db, COLLECTIONS.TESTS, testId));
      
      if (!testDoc.exists()) {
        return null;
      }

      return {
        id: testDoc.id,
        ...testDoc.data(),
        createdAt: testDoc.data().createdAt?.toDate(),
        updatedAt: testDoc.data().updatedAt?.toDate(),
      } as Test;
    } catch (error: any) {
      console.error('Error getting test:', error);
      throw new Error(`Failed to get test: ${error.message}`);
    }
  };

  // Load more tests
  const loadMore = async (): Promise<void> => {
    if (!hasMore || loading) return;
    await loadTests(false);
  };

  // Refresh tests
  const refresh = async (): Promise<void> => {
    setLastDoc(null);
    await loadTests(true);
  };

  // Upload test image
  const uploadTestImage = async (file: File, testId: string): Promise<string> => {
    try {
      const fileName = `${testId}_${Date.now()}_${file.name}`;
      const storageRef = ref(storage, `${STORAGE_PATHS.TEST_IMAGES}/${fileName}`);
      
      const snapshot = await uploadBytes(storageRef, file);
      const downloadURL = await getDownloadURL(snapshot.ref);
      
      return downloadURL;
    } catch (error: any) {
      console.error('Error uploading test image:', error);
      throw new Error(`Failed to upload image: ${error.message}`);
    }
  };

  // Delete test image
  const deleteTestImage = async (imageUrl: string): Promise<void> => {
    try {
      const imageRef = ref(storage, imageUrl);
      await deleteObject(imageRef);
    } catch (error: any) {
      console.error('Error deleting test image:', error);
      // Don't throw error for image deletion failures
    }
  };

  // Toggle test status
  const toggleTestStatus = async (testId: string, isActive: boolean): Promise<void> => {
    await updateTest(testId, { isActive });
  };

  // Duplicate test
  const duplicateTest = async (testId: string): Promise<string> => {
    const originalTest = await getTest(testId);
    if (!originalTest) {
      throw new Error('Test not found');
    }

    const duplicatedTest: TestFormData = {
      name: {
        ar: `${originalTest.name.ar} - نسخة`,
        en: `${originalTest.name.en} - Copy`,
      },
      description: originalTest.description,
      category: originalTest.category,
      reagents: originalTest.reagents,
      expectedResults: originalTest.expectedResults,
      instructions: originalTest.instructions,
      safetyNotes: originalTest.safetyNotes,
      difficulty: originalTest.difficulty,
      estimatedTime: originalTest.estimatedTime,
      tags: originalTest.tags,
      images: [], // Don't copy images
      videos: originalTest.videos,
    };

    return await createTest(duplicatedTest);
  };

  // Bulk update tests
  const bulkUpdateTests = async (testIds: string[], updates: Partial<TestFormData>): Promise<void> => {
    if (!user) throw new Error('User not authenticated');

    try {
      const batch = writeBatch(db);
      
      testIds.forEach(testId => {
        const testRef = doc(db, COLLECTIONS.TESTS, testId);
        batch.update(testRef, {
          ...updates,
          updatedAt: Timestamp.now(),
        });
      });

      await batch.commit();

      // Log analytics
      await logAnalytics('tests_bulk_updated', {
        testIds,
        updatedFields: Object.keys(updates),
        count: testIds.length,
      });
    } catch (error: any) {
      console.error('Error bulk updating tests:', error);
      throw new Error(`Failed to bulk update tests: ${error.message}`);
    }
  };

  return {
    tests,
    loading,
    error,
    hasMore,
    createTest,
    updateTest,
    deleteTest,
    getTest,
    loadMore,
    refresh,
    uploadTestImage,
    deleteTestImage,
    toggleTestStatus,
    duplicateTest,
    bulkUpdateTests,
  };
};
