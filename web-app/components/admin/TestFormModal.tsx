import React, { useState, useEffect } from 'react';
import { useTranslation } from 'next-i18next';
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  XMarkIcon,
  PlusIcon,
  TrashIcon,
  PhotoIcon,
  VideoCameraIcon,
} from '@heroicons/react/24/outline';
import { toast } from 'react-hot-toast';

import Modal from '../common/Modal';
import FormInput from '../common/FormInput';
import FormTextarea from '../common/FormTextarea';
import FormSelect from '../common/FormSelect';
import ImageUpload from '../common/ImageUpload';
import { useTests } from '../../hooks/useTests';
import { Test, TestFormData, Reagent } from '../../types/test';

// Validation schema
const testSchema = z.object({
  name: z.object({
    ar: z.string().min(1, 'Arabic name is required'),
    en: z.string().min(1, 'English name is required'),
  }),
  description: z.object({
    ar: z.string().min(1, 'Arabic description is required'),
    en: z.string().min(1, 'English description is required'),
  }),
  category: z.string().min(1, 'Category is required'),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  estimatedTime: z.number().min(1, 'Estimated time must be at least 1 minute'),
  reagents: z.array(z.object({
    id: z.string(),
    name: z.object({
      ar: z.string().min(1, 'Reagent Arabic name is required'),
      en: z.string().min(1, 'Reagent English name is required'),
    }),
    amount: z.string().min(1, 'Amount is required'),
    unit: z.string().min(1, 'Unit is required'),
  })).min(1, 'At least one reagent is required'),
  instructions: z.object({
    ar: z.array(z.string().min(1)).min(1, 'At least one Arabic instruction is required'),
    en: z.array(z.string().min(1)).min(1, 'At least one English instruction is required'),
  }),
  safetyNotes: z.object({
    ar: z.array(z.string()),
    en: z.array(z.string()),
  }),
  tags: z.array(z.string()),
  expectedResults: z.array(z.object({
    substance: z.string().min(1, 'Substance name is required'),
    color: z.string().min(1, 'Expected color is required'),
    description: z.object({
      ar: z.string().min(1, 'Arabic description is required'),
      en: z.string().min(1, 'English description is required'),
    }),
  })),
});

interface TestFormModalProps {
  test?: Test | null;
  onClose: () => void;
  onSave: () => void;
}

const TestFormModal: React.FC<TestFormModalProps> = ({ test, onClose, onSave }) => {
  const { t } = useTranslation(['tests', 'common']);
  const { createTest, updateTest, uploadTestImage } = useTests();
  const [loading, setLoading] = useState(false);
  const [uploadingImages, setUploadingImages] = useState(false);

  const {
    register,
    control,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<TestFormData>({
    resolver: zodResolver(testSchema),
    defaultValues: test ? {
      name: test.name,
      description: test.description,
      category: test.category,
      difficulty: test.difficulty,
      estimatedTime: test.estimatedTime,
      reagents: test.reagents,
      instructions: test.instructions,
      safetyNotes: test.safetyNotes,
      tags: test.tags,
      expectedResults: test.expectedResults,
      images: test.images || [],
      videos: test.videos || [],
    } : {
      name: { ar: '', en: '' },
      description: { ar: '', en: '' },
      category: '',
      difficulty: 'beginner',
      estimatedTime: 30,
      reagents: [{ id: '', name: { ar: '', en: '' }, amount: '', unit: 'ml' }],
      instructions: { ar: [''], en: [''] },
      safetyNotes: { ar: [], en: [] },
      tags: [],
      expectedResults: [],
      images: [],
      videos: [],
    },
  });

  const {
    fields: reagentFields,
    append: appendReagent,
    remove: removeReagent,
  } = useFieldArray({
    control,
    name: 'reagents',
  });

  const {
    fields: instructionArFields,
    append: appendInstructionAr,
    remove: removeInstructionAr,
  } = useFieldArray({
    control,
    name: 'instructions.ar',
  });

  const {
    fields: instructionEnFields,
    append: appendInstructionEn,
    remove: removeInstructionEn,
  } = useFieldArray({
    control,
    name: 'instructions.en',
  });

  const {
    fields: expectedResultFields,
    append: appendExpectedResult,
    remove: removeExpectedResult,
  } = useFieldArray({
    control,
    name: 'expectedResults',
  });

  // Category options
  const categoryOptions = [
    { value: 'drugs', label: t('categories.drugs') },
    { value: 'chemicals', label: t('categories.chemicals') },
    { value: 'forensic', label: t('categories.forensic') },
    { value: 'medical', label: t('categories.medical') },
  ];

  // Difficulty options
  const difficultyOptions = [
    { value: 'beginner', label: t('difficulty.beginner') },
    { value: 'intermediate', label: t('difficulty.intermediate') },
    { value: 'advanced', label: t('difficulty.advanced') },
  ];

  // Unit options
  const unitOptions = [
    { value: 'ml', label: 'ml' },
    { value: 'g', label: 'g' },
    { value: 'drops', label: t('units.drops') },
    { value: 'pieces', label: t('units.pieces') },
  ];

  // Handle form submission
  const onSubmit = async (data: TestFormData) => {
    try {
      setLoading(true);

      if (test) {
        await updateTest(test.id, data);
        toast.success(t('messages.updateSuccess'));
      } else {
        await createTest(data);
        toast.success(t('messages.createSuccess'));
      }

      onSave();
    } catch (error: any) {
      toast.error(error.message || t('messages.saveError'));
    } finally {
      setLoading(false);
    }
  };

  // Handle image upload
  const handleImageUpload = async (files: File[]) => {
    if (!test && !test?.id) {
      toast.error(t('messages.saveTestFirst'));
      return;
    }

    try {
      setUploadingImages(true);
      const uploadPromises = files.map(file => uploadTestImage(file, test!.id));
      const imageUrls = await Promise.all(uploadPromises);
      
      const currentImages = watch('images') || [];
      setValue('images', [...currentImages, ...imageUrls]);
      
      toast.success(t('messages.imagesUploaded'));
    } catch (error: any) {
      toast.error(error.message || t('messages.imageUploadError'));
    } finally {
      setUploadingImages(false);
    }
  };

  return (
    <Modal
      isOpen={true}
      onClose={onClose}
      title={test ? t('actions.editTest') : t('actions.createTest')}
      size="4xl"
    >
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Basic Information */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
          <div>
            <FormInput
              label={t('fields.nameAr')}
              {...register('name.ar')}
              error={errors.name?.ar?.message}
              required
            />
          </div>
          <div>
            <FormInput
              label={t('fields.nameEn')}
              {...register('name.en')}
              error={errors.name?.en?.message}
              required
            />
          </div>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
          <div>
            <FormTextarea
              label={t('fields.descriptionAr')}
              {...register('description.ar')}
              error={errors.description?.ar?.message}
              rows={3}
              required
            />
          </div>
          <div>
            <FormTextarea
              label={t('fields.descriptionEn')}
              {...register('description.en')}
              error={errors.description?.en?.message}
              rows={3}
              required
            />
          </div>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
          <FormSelect
            label={t('fields.category')}
            {...register('category')}
            options={categoryOptions}
            error={errors.category?.message}
            required
          />
          <FormSelect
            label={t('fields.difficulty')}
            {...register('difficulty')}
            options={difficultyOptions}
            error={errors.difficulty?.message}
            required
          />
          <FormInput
            label={t('fields.estimatedTime')}
            type="number"
            {...register('estimatedTime', { valueAsNumber: true })}
            error={errors.estimatedTime?.message}
            min={1}
            required
          />
        </div>

        {/* Reagents */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-medium text-gray-900">{t('sections.reagents')}</h3>
            <button
              type="button"
              onClick={() => appendReagent({ id: '', name: { ar: '', en: '' }, amount: '', unit: 'ml' })}
              className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-primary-700 bg-primary-100 hover:bg-primary-200"
            >
              <PlusIcon className="-ml-0.5 mr-2 h-4 w-4" />
              {t('actions.addReagent')}
            </button>
          </div>
          
          <div className="space-y-4">
            {reagentFields.map((field, index) => (
              <div key={field.id} className="grid grid-cols-1 gap-4 sm:grid-cols-6 items-end">
                <div className="sm:col-span-2">
                  <FormInput
                    label={t('fields.reagentNameAr')}
                    {...register(`reagents.${index}.name.ar`)}
                    error={errors.reagents?.[index]?.name?.ar?.message}
                    required
                  />
                </div>
                <div className="sm:col-span-2">
                  <FormInput
                    label={t('fields.reagentNameEn')}
                    {...register(`reagents.${index}.name.en`)}
                    error={errors.reagents?.[index]?.name?.en?.message}
                    required
                  />
                </div>
                <div>
                  <FormInput
                    label={t('fields.amount')}
                    {...register(`reagents.${index}.amount`)}
                    error={errors.reagents?.[index]?.amount?.message}
                    required
                  />
                </div>
                <div>
                  <FormSelect
                    label={t('fields.unit')}
                    {...register(`reagents.${index}.unit`)}
                    options={unitOptions}
                    error={errors.reagents?.[index]?.unit?.message}
                    required
                  />
                </div>
                {reagentFields.length > 1 && (
                  <div>
                    <button
                      type="button"
                      onClick={() => removeReagent(index)}
                      className="inline-flex items-center p-2 border border-transparent rounded-md text-red-700 bg-red-100 hover:bg-red-200"
                    >
                      <TrashIcon className="h-4 w-4" />
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Instructions */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
          <div>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">{t('sections.instructionsAr')}</h3>
              <button
                type="button"
                onClick={() => appendInstructionAr('')}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-primary-700 bg-primary-100 hover:bg-primary-200"
              >
                <PlusIcon className="-ml-0.5 mr-2 h-4 w-4" />
                {t('actions.addStep')}
              </button>
            </div>
            <div className="space-y-3">
              {instructionArFields.map((field, index) => (
                <div key={field.id} className="flex items-center space-x-2">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-800 rounded-full flex items-center justify-center text-sm font-medium">
                    {index + 1}
                  </span>
                  <FormTextarea
                    {...register(`instructions.ar.${index}`)}
                    error={errors.instructions?.ar?.[index]?.message}
                    rows={2}
                    required
                  />
                  {instructionArFields.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeInstructionAr(index)}
                      className="flex-shrink-0 p-1 text-red-600 hover:text-red-800"
                    >
                      <TrashIcon className="h-4 w-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>

          <div>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium text-gray-900">{t('sections.instructionsEn')}</h3>
              <button
                type="button"
                onClick={() => appendInstructionEn('')}
                className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-primary-700 bg-primary-100 hover:bg-primary-200"
              >
                <PlusIcon className="-ml-0.5 mr-2 h-4 w-4" />
                {t('actions.addStep')}
              </button>
            </div>
            <div className="space-y-3">
              {instructionEnFields.map((field, index) => (
                <div key={field.id} className="flex items-center space-x-2">
                  <span className="flex-shrink-0 w-6 h-6 bg-primary-100 text-primary-800 rounded-full flex items-center justify-center text-sm font-medium">
                    {index + 1}
                  </span>
                  <FormTextarea
                    {...register(`instructions.en.${index}`)}
                    error={errors.instructions?.en?.[index]?.message}
                    rows={2}
                    required
                  />
                  {instructionEnFields.length > 1 && (
                    <button
                      type="button"
                      onClick={() => removeInstructionEn(index)}
                      className="flex-shrink-0 p-1 text-red-600 hover:text-red-800"
                    >
                      <TrashIcon className="h-4 w-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Form Actions */}
        <div className="flex justify-end space-x-3 pt-6 border-t border-gray-200">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
            disabled={loading}
          >
            {t('common:cancel')}
          </button>
          <button
            type="submit"
            className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 disabled:opacity-50"
            disabled={loading}
          >
            {loading ? t('common:saving') : (test ? t('common:update') : t('common:create'))}
          </button>
        </div>
      </form>
    </Modal>
  );
};

export default TestFormModal;
