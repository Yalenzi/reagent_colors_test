import React, { useState, useEffect } from 'react';
import { NextPage } from 'next';
import { useRouter } from 'next/router';
import { useTranslation } from 'next-i18next';
import { serverSideTranslations } from 'next-i18next/serverSideTranslations';
import {
  ChartBarIcon,
  UsersIcon,
  BeakerIcon,
  DocumentTextIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon,
  ClockIcon,
  EyeIcon,
} from '@heroicons/react/24/outline';

import AdminLayout from '../../components/layouts/AdminLayout';
import StatsCard from '../../components/admin/StatsCard';
import RecentActivity from '../../components/admin/RecentActivity';
import QuickActions from '../../components/admin/QuickActions';
import AnalyticsChart from '../../components/admin/AnalyticsChart';
import { useAuth } from '../../hooks/useAuth';
import { useAdminStats } from '../../hooks/useAdminStats';
import { withAdminAuth } from '../../hoc/withAdminAuth';

interface DashboardStats {
  totalUsers: number;
  totalTests: number;
  totalResults: number;
  activeUsers: number;
  testsToday: number;
  resultsToday: number;
  pendingReviews: number;
  systemAlerts: number;
}

const AdminDashboard: NextPage = () => {
  const { t } = useTranslation(['admin', 'common']);
  const router = useRouter();
  const { user } = useAuth();
  const { stats, loading, error } = useAdminStats();
  
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d'>('30d');

  // Quick stats data
  const quickStats = [
    {
      title: t('dashboard.stats.totalUsers'),
      value: stats?.totalUsers || 0,
      change: '+12%',
      changeType: 'positive' as const,
      icon: UsersIcon,
      color: 'blue',
    },
    {
      title: t('dashboard.stats.totalTests'),
      value: stats?.totalTests || 0,
      change: '+5%',
      changeType: 'positive' as const,
      icon: BeakerIcon,
      color: 'green',
    },
    {
      title: t('dashboard.stats.totalResults'),
      value: stats?.totalResults || 0,
      change: '+18%',
      changeType: 'positive' as const,
      icon: DocumentTextIcon,
      color: 'purple',
    },
    {
      title: t('dashboard.stats.activeUsers'),
      value: stats?.activeUsers || 0,
      change: '+8%',
      changeType: 'positive' as const,
      icon: EyeIcon,
      color: 'orange',
    },
  ];

  // Alert stats
  const alertStats = [
    {
      title: t('dashboard.alerts.pendingReviews'),
      value: stats?.pendingReviews || 0,
      icon: ClockIcon,
      color: 'yellow',
      urgent: (stats?.pendingReviews || 0) > 10,
    },
    {
      title: t('dashboard.alerts.systemAlerts'),
      value: stats?.systemAlerts || 0,
      icon: ExclamationTriangleIcon,
      color: 'red',
      urgent: (stats?.systemAlerts || 0) > 0,
    },
  ];

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
        </div>
      </AdminLayout>
    );
  }

  if (error) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="text-center">
            <ExclamationTriangleIcon className="mx-auto h-12 w-12 text-red-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">
              {t('common:errors.loadingError')}
            </h3>
            <p className="mt-1 text-sm text-gray-500">{error}</p>
          </div>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="md:flex md:items-center md:justify-between">
          <div className="flex-1 min-w-0">
            <h2 className="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
              {t('dashboard.title')}
            </h2>
            <p className="mt-1 text-sm text-gray-500">
              {t('dashboard.welcome', { name: user?.displayName || user?.email })}
            </p>
          </div>
          <div className="mt-4 flex md:mt-0 md:ml-4">
            <select
              value={timeRange}
              onChange={(e) => setTimeRange(e.target.value as '7d' | '30d' | '90d')}
              className="block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md"
            >
              <option value="7d">{t('dashboard.timeRange.7d')}</option>
              <option value="30d">{t('dashboard.timeRange.30d')}</option>
              <option value="90d">{t('dashboard.timeRange.90d')}</option>
            </select>
          </div>
        </div>

        {/* Quick Stats */}
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {quickStats.map((stat, index) => (
            <StatsCard key={index} {...stat} />
          ))}
        </div>

        {/* Alert Stats */}
        {alertStats.some(stat => stat.value > 0) && (
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
            {alertStats.map((stat, index) => (
              <StatsCard key={index} {...stat} />
            ))}
          </div>
        )}

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
          {/* Analytics Chart */}
          <div className="lg:col-span-2">
            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg leading-6 font-medium text-gray-900">
                    {t('dashboard.analytics.title')}
                  </h3>
                  <ChartBarIcon className="h-5 w-5 text-gray-400" />
                </div>
                <AnalyticsChart timeRange={timeRange} />
              </div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="space-y-6">
            <QuickActions />
            <RecentActivity />
          </div>
        </div>

        {/* Recent Activity Table */}
        <div className="bg-white shadow overflow-hidden sm:rounded-md">
          <div className="px-4 py-5 sm:px-6">
            <h3 className="text-lg leading-6 font-medium text-gray-900">
              {t('dashboard.recentActivity.title')}
            </h3>
            <p className="mt-1 max-w-2xl text-sm text-gray-500">
              {t('dashboard.recentActivity.description')}
            </p>
          </div>
          <div className="border-t border-gray-200">
            <RecentActivity detailed />
          </div>
        </div>
      </div>
    </AdminLayout>
  );
};

export const getServerSideProps = async ({ locale }: { locale: string }) => {
  return {
    props: {
      ...(await serverSideTranslations(locale, ['admin', 'common', 'navigation'])),
    },
  };
};

export default withAdminAuth(AdminDashboard);
