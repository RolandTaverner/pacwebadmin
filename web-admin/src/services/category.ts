import { api } from './api';

import type {
  Category, CategoriesResponse,
  CategoryGetByIdResponse,
  CategoryFilterRequest,
  CategoryCreateRequest, CategoryCreateResponse,
  CategoryUpdateRequest, CategoryUpdateResponse
} from './types';

const categoryApi = api.injectEndpoints({
  endpoints: (builder) => ({
    allCategories: builder.query<Category[], void>(
      {
        query: () => ({ url: '/category/list' }),
        transformResponse: (response: CategoriesResponse): Category[] => response.categories,
        providesTags: (result, error) => result
          ? [
            ...result.map(({ id }) => ({ type: 'Category' as const, id })),
            { type: 'Category', id: 'LIST' },
          ]
          : [{ type: 'Category', id: 'LIST' }],

      }
    ),
    filterCategories: builder.query<Category[], CategoryFilterRequest>(
      {
        query: (filter) => ({ url: '/category/filter', method: 'POST', body: filter }),
        transformResponse: (response: CategoriesResponse): Category[] => response.categories,
        providesTags: (result, error, filter) => result
          ? [...result.map(({ id }) => ({ type: 'Category' as const, id })), { type: 'Category', id: 'LIST' }]
          : [{ type: 'Category', id: 'LIST' }],
      }
    ),
    byIdCategory: builder.query<Category, number>(
      {
        query: (id) => ({ url: `/category/list/${id}` }),
        transformResponse: (response: CategoryGetByIdResponse): Category => response,
        providesTags: (result, error, id) => [{ type: 'Category', id }],
      }
    ),
    createCategory: builder.mutation<Category, CategoryCreateRequest>({
      query: (createRequest) => ({ url: '/category/list', method: 'POST', body: createRequest }),
      transformResponse: (response: CategoryCreateResponse): Category => response,
      invalidatesTags: [{ type: 'Category', id: 'LIST' }],
    }),
    updateCategory: builder.mutation<Category, { id: number, body: CategoryUpdateRequest }>({
      query: (updateRequest) => ({ url: `/category/list/${updateRequest.id}`, method: 'PUT', body: updateRequest.body }),
      transformResponse: (response: CategoryUpdateResponse): Category => response,
      invalidatesTags: (result, error, updateRequest) => result ? [
        { type: 'Category', id: result.id }, { type: 'Category', id: 'LIST' }, { type: 'PACPreview' }]
        : [{ type: 'Category', id: 'LIST' }],
    }),
    deleteCategory: builder.mutation<void, number>({
      query: (id) => ({ url: `/category/list/${id}`, method: 'DELETE' }),
      invalidatesTags: (result, error, id) => error ? [
      ]
        : [{ type: 'Category', id },
        { type: 'Category', id: 'LIST' },]
    }),
  }),
  overrideExisting: false,
})

export const { useAllCategoriesQuery, useFilterCategoriesQuery, useByIdCategoryQuery, useCreateCategoryMutation, useUpdateCategoryMutation, useDeleteCategoryMutation } = categoryApi;
