import React, { useState, useEffect } from 'react';
import { NextPage } from 'next';
import { useRouter } from 'next/router';
import { useTranslation } from 'next-i18next';
import { serverSideTranslations } from 'next-i18next/serverSideTranslations';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  FunnelIcon,
  EyeIcon,
  PencilIcon,
  TrashIcon,
  BeakerIcon,
} from '@heroicons/react/24/outline';
import { toast } from 'react-hot-toast';

import AdminLayout from '../../../components/layouts/AdminLayout';
import DataTable from '../../../components/admin/DataTable';
import SearchInput from '../../../components/common/SearchInput';
import FilterDropdown from '../../../components/common/FilterDropdown';
import ConfirmDialog from '../../../components/common/ConfirmDialog';
import TestFormModal from '../../../components/admin/TestFormModal';
import { useTests } from '../../../hooks/useTests';
import { useAuth } from '../../../hooks/useAuth';
import { withAdminAuth } from '../../../hoc/withAdminAuth';
import { Test } from '../../../types/test';

const TestsManagement: NextPage = () => {
  const { t } = useTranslation(['admin', 'common', 'tests']);
  const router = useRouter();
  const { user } = useAuth();
  const { tests, loading, error, deleteTest, updateTest } = useTests();

  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [showTestModal, setShowTestModal] = useState(false);
  const [editingTest, setEditingTest] = useState<Test | null>(null);
  const [deletingTest, setDeletingTest] = useState<Test | null>(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);

  // Filter tests based on search and filters
  const filteredTests = tests.filter((test) => {
    const matchesSearch = 
      test.name.ar.toLowerCase().includes(searchTerm.toLowerCase()) ||
      test.name.en.toLowerCase().includes(searchTerm.toLowerCase()) ||
      test.description.ar.toLowerCase().includes(searchTerm.toLowerCase()) ||
      test.description.en.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesCategory = selectedCategory === 'all' || test.category === selectedCategory;
    const matchesStatus = selectedStatus === 'all' || 
      (selectedStatus === 'active' && test.isActive) ||
      (selectedStatus === 'inactive' && !test.isActive);

    return matchesSearch && matchesCategory && matchesStatus;
  });

  // Table columns configuration
  const columns = [
    {
      key: 'name',
      title: t('tests:fields.name'),
      render: (test: Test) => (
        <div className="flex items-center">
          <BeakerIcon className="h-5 w-5 text-gray-400 mr-3" />
          <div>
            <div className="text-sm font-medium text-gray-900">
              {test.name.ar}
            </div>
            <div className="text-sm text-gray-500">
              {test.name.en}
            </div>
          </div>
        </div>
      ),
    },
    {
      key: 'category',
      title: t('tests:fields.category'),
      render: (test: Test) => (
        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
          {test.category}
        </span>
      ),
    },
    {
      key: 'difficulty',
      title: t('tests:fields.difficulty'),
      render: (test: Test) => {
        const colors = {
          beginner: 'bg-green-100 text-green-800',
          intermediate: 'bg-yellow-100 text-yellow-800',
          advanced: 'bg-red-100 text-red-800',
        };
        return (
          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${colors[test.difficulty]}`}>
            {t(`tests:difficulty.${test.difficulty}`)}
          </span>
        );
      },
    },
    {
      key: 'reagents',
      title: t('tests:fields.reagents'),
      render: (test: Test) => (
        <span className="text-sm text-gray-900">
          {test.reagents.length} {t('tests:reagentsCount')}
        </span>
      ),
    },
    {
      key: 'estimatedTime',
      title: t('tests:fields.estimatedTime'),
      render: (test: Test) => (
        <span className="text-sm text-gray-900">
          {test.estimatedTime} {t('common:minutes')}
        </span>
      ),
    },
    {
      key: 'status',
      title: t('common:status'),
      render: (test: Test) => (
        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
          test.isActive 
            ? 'bg-green-100 text-green-800' 
            : 'bg-gray-100 text-gray-800'
        }`}>
          {test.isActive ? t('common:active') : t('common:inactive')}
        </span>
      ),
    },
    {
      key: 'actions',
      title: t('common:actions'),
      render: (test: Test) => (
        <div className="flex items-center space-x-2">
          <button
            onClick={() => router.push(`/admin/tests/${test.id}`)}
            className="text-blue-600 hover:text-blue-900"
            title={t('common:view')}
          >
            <EyeIcon className="h-4 w-4" />
          </button>
          <button
            onClick={() => handleEditTest(test)}
            className="text-green-600 hover:text-green-900"
            title={t('common:edit')}
          >
            <PencilIcon className="h-4 w-4" />
          </button>
          <button
            onClick={() => handleDeleteTest(test)}
            className="text-red-600 hover:text-red-900"
            title={t('common:delete')}
          >
            <TrashIcon className="h-4 w-4" />
          </button>
        </div>
      ),
    },
  ];

  // Filter options
  const categoryOptions = [
    { value: 'all', label: t('common:all') },
    { value: 'drugs', label: t('tests:categories.drugs') },
    { value: 'chemicals', label: t('tests:categories.chemicals') },
    { value: 'forensic', label: t('tests:categories.forensic') },
  ];

  const statusOptions = [
    { value: 'all', label: t('common:all') },
    { value: 'active', label: t('common:active') },
    { value: 'inactive', label: t('common:inactive') },
  ];

  // Event handlers
  const handleCreateTest = () => {
    setEditingTest(null);
    setShowTestModal(true);
  };

  const handleEditTest = (test: Test) => {
    setEditingTest(test);
    setShowTestModal(true);
  };

  const handleDeleteTest = (test: Test) => {
    setDeletingTest(test);
    setShowDeleteDialog(true);
  };

  const confirmDelete = async () => {
    if (!deletingTest) return;

    try {
      await deleteTest(deletingTest.id);
      toast.success(t('tests:messages.deleteSuccess'));
      setShowDeleteDialog(false);
      setDeletingTest(null);
    } catch (error) {
      toast.error(t('tests:messages.deleteError'));
    }
  };

  const handleTestSaved = () => {
    setShowTestModal(false);
    setEditingTest(null);
    toast.success(editingTest ? t('tests:messages.updateSuccess') : t('tests:messages.createSuccess'));
  };

  if (loading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center min-h-screen">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-600"></div>
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
              {t('admin:navigation.tests')}
            </h2>
            <p className="mt-1 text-sm text-gray-500">
              {t('tests:management.description')}
            </p>
          </div>
          <div className="mt-4 flex md:mt-0 md:ml-4">
            <button
              onClick={handleCreateTest}
              className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              <PlusIcon className="-ml-1 mr-2 h-5 w-5" />
              {t('tests:actions.create')}
            </button>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white shadow rounded-lg p-6">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <SearchInput
              placeholder={t('tests:search.placeholder')}
              value={searchTerm}
              onChange={setSearchTerm}
            />
            <FilterDropdown
              label={t('tests:filters.category')}
              options={categoryOptions}
              value={selectedCategory}
              onChange={setSelectedCategory}
            />
            <FilterDropdown
              label={t('tests:filters.status')}
              options={statusOptions}
              value={selectedStatus}
              onChange={setSelectedStatus}
            />
          </div>
        </div>

        {/* Tests Table */}
        <div className="bg-white shadow overflow-hidden sm:rounded-md">
          <DataTable
            data={filteredTests}
            columns={columns}
            loading={loading}
            emptyMessage={t('tests:empty.message')}
            emptyDescription={t('tests:empty.description')}
          />
        </div>

        {/* Test Form Modal */}
        {showTestModal && (
          <TestFormModal
            test={editingTest}
            onClose={() => setShowTestModal(false)}
            onSave={handleTestSaved}
          />
        )}

        {/* Delete Confirmation Dialog */}
        <ConfirmDialog
          isOpen={showDeleteDialog}
          onClose={() => setShowDeleteDialog(false)}
          onConfirm={confirmDelete}
          title={t('tests:delete.title')}
          message={t('tests:delete.message', { name: deletingTest?.name.ar })}
          confirmText={t('common:delete')}
          cancelText={t('common:cancel')}
          type="danger"
        />
      </div>
    </AdminLayout>
  );
};

export const getServerSideProps = async ({ locale }: { locale: string }) => {
  return {
    props: {
      ...(await serverSideTranslations(locale, ['admin', 'common', 'tests'])),
    },
  };
};

export default withAdminAuth(TestsManagement);
