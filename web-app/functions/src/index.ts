import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { FieldValue } from 'firebase-admin/firestore';

// Initialize Firebase Admin
admin.initializeApp();
const db = admin.firestore();

// Collection names
const COLLECTIONS = {
  USERS: 'users',
  TESTS: 'tests',
  REAGENTS: 'reagents',
  TEST_RESULTS: 'testResults',
  CATEGORIES: 'categories',
  ANALYTICS: 'analytics',
  NOTIFICATIONS: 'notifications',
  SETTINGS: 'settings',
};

// Test synchronization trigger
export const onTestWrite = functions.firestore
  .document(`${COLLECTIONS.TESTS}/{testId}`)
  .onWrite(async (change, context) => {
    const testId = context.params.testId;
    
    try {
      // Handle test creation
      if (!change.before.exists && change.after.exists) {
        const testData = change.after.data();
        
        // Send notification to all admin users
        await notifyAdmins('test_created', {
          title: {
            ar: 'تم إنشاء اختبار جديد',
            en: 'New test created',
          },
          message: {
            ar: `تم إنشاء اختبار جديد: ${testData?.name?.ar}`,
            en: `New test created: ${testData?.name?.en}`,
          },
          data: {
            testId,
            type: 'test_created',
            testName: testData?.name,
          },
        });

        // Update category test count
        if (testData?.category) {
          await updateCategoryCount(testData.category, 1);
        }

        // Log analytics
        await logAnalytics('test_created', {
          testId,
          category: testData?.category,
          difficulty: testData?.difficulty,
          createdBy: testData?.createdBy,
        });
      }
      
      // Handle test update
      else if (change.before.exists && change.after.exists) {
        const beforeData = change.before.data();
        const afterData = change.after.data();
        
        // Check if test status changed
        if (beforeData?.isActive !== afterData?.isActive) {
          await notifyAdmins('test_status_changed', {
            title: {
              ar: 'تم تغيير حالة الاختبار',
              en: 'Test status changed',
            },
            message: {
              ar: `تم ${afterData?.isActive ? 'تفعيل' : 'إلغاء تفعيل'} اختبار: ${afterData?.name?.ar}`,
              en: `Test ${afterData?.isActive ? 'activated' : 'deactivated'}: ${afterData?.name?.en}`,
            },
            data: {
              testId,
              type: 'test_status_changed',
              isActive: afterData?.isActive,
              testName: afterData?.name,
            },
          });
        }

        // Update category counts if category changed
        if (beforeData?.category !== afterData?.category) {
          if (beforeData?.category) {
            await updateCategoryCount(beforeData.category, -1);
          }
          if (afterData?.category) {
            await updateCategoryCount(afterData.category, 1);
          }
        }

        // Log analytics
        await logAnalytics('test_updated', {
          testId,
          updatedFields: getChangedFields(beforeData, afterData),
          updatedBy: afterData?.updatedBy,
        });
      }
      
      // Handle test deletion
      else if (change.before.exists && !change.after.exists) {
        const testData = change.before.data();
        
        // Send notification to all admin users
        await notifyAdmins('test_deleted', {
          title: {
            ar: 'تم حذف اختبار',
            en: 'Test deleted',
          },
          message: {
            ar: `تم حذف اختبار: ${testData?.name?.ar}`,
            en: `Test deleted: ${testData?.name?.en}`,
          },
          data: {
            testId,
            type: 'test_deleted',
            testName: testData?.name,
          },
        });

        // Update category test count
        if (testData?.category) {
          await updateCategoryCount(testData.category, -1);
        }

        // Log analytics
        await logAnalytics('test_deleted', {
          testId,
          category: testData?.category,
          deletedBy: testData?.deletedBy,
        });
      }
    } catch (error) {
      console.error('Error in onTestWrite:', error);
    }
  });

// Test result synchronization trigger
export const onTestResultWrite = functions.firestore
  .document(`${COLLECTIONS.TEST_RESULTS}/{resultId}`)
  .onWrite(async (change, context) => {
    const resultId = context.params.resultId;
    
    try {
      // Handle new test result
      if (!change.before.exists && change.after.exists) {
        const resultData = change.after.data();
        
        // Update test statistics
        if (resultData?.testId) {
          await updateTestStats(resultData.testId);
        }

        // Send notification to test creator and admins
        if (resultData?.testId) {
          const testDoc = await db.collection(COLLECTIONS.TESTS).doc(resultData.testId).get();
          if (testDoc.exists) {
            const testData = testDoc.data();
            
            // Notify test creator
            if (testData?.createdBy && testData.createdBy !== resultData?.userId) {
              await sendNotification(testData.createdBy, {
                title: {
                  ar: 'نتيجة اختبار جديدة',
                  en: 'New test result',
                },
                message: {
                  ar: `تم إجراء اختبار: ${testData?.name?.ar}`,
                  en: `Test performed: ${testData?.name?.en}`,
                },
                data: {
                  resultId,
                  testId: resultData.testId,
                  type: 'test_result_created',
                },
              });
            }
          }
        }

        // Log analytics
        await logAnalytics('test_result_created', {
          resultId,
          testId: resultData?.testId,
          userId: resultData?.userId,
          isVerified: resultData?.isVerified,
        });
      }
      
      // Handle result verification
      else if (change.before.exists && change.after.exists) {
        const beforeData = change.before.data();
        const afterData = change.after.data();
        
        if (!beforeData?.isVerified && afterData?.isVerified) {
          // Send notification to result owner
          if (afterData?.userId) {
            await sendNotification(afterData.userId, {
              title: {
                ar: 'تم التحقق من النتيجة',
                en: 'Result verified',
              },
              message: {
                ar: 'تم التحقق من نتيجة اختبارك من قبل المشرف',
                en: 'Your test result has been verified by an admin',
              },
              data: {
                resultId,
                testId: afterData?.testId,
                type: 'result_verified',
              },
            });
          }

          // Log analytics
          await logAnalytics('test_result_verified', {
            resultId,
            testId: afterData?.testId,
            verifiedBy: afterData?.verifiedBy,
          });
        }
      }
    } catch (error) {
      console.error('Error in onTestResultWrite:', error);
    }
  });

// User activity tracking
export const onUserWrite = functions.firestore
  .document(`${COLLECTIONS.USERS}/{userId}`)
  .onWrite(async (change, context) => {
    const userId = context.params.userId;
    
    try {
      // Handle new user registration
      if (!change.before.exists && change.after.exists) {
        const userData = change.after.data();
        
        // Send welcome notification
        await sendNotification(userId, {
          title: {
            ar: 'مرحباً بك في ColorTests',
            en: 'Welcome to ColorTests',
          },
          message: {
            ar: 'مرحباً بك في منصة اختبار الألوان العلمية',
            en: 'Welcome to the scientific color testing platform',
          },
          data: {
            type: 'welcome',
          },
        });

        // Notify admins of new user
        await notifyAdmins('new_user_registered', {
          title: {
            ar: 'مستخدم جديد',
            en: 'New user registered',
          },
          message: {
            ar: `انضم مستخدم جديد: ${userData?.displayName || userData?.email}`,
            en: `New user joined: ${userData?.displayName || userData?.email}`,
          },
          data: {
            userId,
            type: 'new_user_registered',
            userEmail: userData?.email,
          },
        });

        // Log analytics
        await logAnalytics('user_registered', {
          userId,
          email: userData?.email,
          registrationMethod: userData?.registrationMethod,
        });
      }
    } catch (error) {
      console.error('Error in onUserWrite:', error);
    }
  });

// Scheduled function to clean up old analytics data
export const cleanupAnalytics = functions.pubsub
  .schedule('0 2 * * *') // Run daily at 2 AM
  .timeZone('Asia/Kuwait')
  .onRun(async (context) => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const oldAnalytics = await db
        .collection(COLLECTIONS.ANALYTICS)
        .where('timestamp', '<', thirtyDaysAgo)
        .limit(500)
        .get();

      const batch = db.batch();
      oldAnalytics.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      
      console.log(`Cleaned up ${oldAnalytics.docs.length} old analytics records`);
    } catch (error) {
      console.error('Error cleaning up analytics:', error);
    }
  });

// Helper functions
async function notifyAdmins(type: string, notification: any) {
  try {
    const adminUsers = await db
      .collection(COLLECTIONS.USERS)
      .where('role', 'in', ['admin', 'moderator'])
      .get();

    const promises = adminUsers.docs.map(doc => 
      sendNotification(doc.id, notification)
    );

    await Promise.all(promises);
  } catch (error) {
    console.error('Error notifying admins:', error);
  }
}

async function sendNotification(userId: string, notification: any) {
  try {
    await db.collection(COLLECTIONS.NOTIFICATIONS).add({
      userId,
      ...notification,
      isRead: false,
      createdAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

async function updateCategoryCount(categoryId: string, increment: number) {
  try {
    const categoryRef = db.collection(COLLECTIONS.CATEGORIES).doc(categoryId);
    await categoryRef.update({
      testsCount: FieldValue.increment(increment),
      updatedAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error('Error updating category count:', error);
  }
}

async function updateTestStats(testId: string) {
  try {
    const testRef = db.collection(COLLECTIONS.TESTS).doc(testId);
    await testRef.update({
      resultsCount: FieldValue.increment(1),
      lastResultAt: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error('Error updating test stats:', error);
  }
}

async function logAnalytics(type: string, data: any) {
  try {
    await db.collection(COLLECTIONS.ANALYTICS).add({
      type,
      data,
      timestamp: FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error('Error logging analytics:', error);
  }
}

function getChangedFields(before: any, after: any): string[] {
  const changedFields: string[] = [];
  
  for (const key in after) {
    if (JSON.stringify(before[key]) !== JSON.stringify(after[key])) {
      changedFields.push(key);
    }
  }
  
  return changedFields;
}
