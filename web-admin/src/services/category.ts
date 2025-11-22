import { api } from './api'

import type {
    Category, CategoriesResponse,
    CategoryGetByIdResponse,
    CategoryFilterRequest,
    CategoryCreateRequest, CategoryCreateResponse,
    CategoryUpdateRequest, CategoryUpdateResponse
} from './types'

const categoryApi = api.injectEndpoints({
    endpoints: (builder) => ({
        all: builder.query<Category[], void>(
            {
                query: () => ({ url: '/category/all' }),
                transformResponse: (response: CategoriesResponse): Category[] => response.categories,
                providesTags: (result, error) => result
                    ? [
                        ...result.map(({ id }) => ({ type: 'Category' as const, id })),
                        { type: 'Category', id: 'LIST' },
                    ]
                    : [{ type: 'Category', id: 'LIST' }],

            }
        ),
        filter: builder.query<Category[], CategoryFilterRequest>(
            {
                query: (filter) => ({ url: '/category/filter', method: 'POST', body: filter }),
                transformResponse: (response: CategoriesResponse): Category[] => response.categories,
                providesTags: (result, error, filter) => result
                    ? [...result.map(({ id }) => ({ type: 'Category' as const, id })), { type: 'Category', id: 'LIST' }]
                    : [{ type: 'Category', id: 'LIST' }],
            }
        ),
        byId: builder.query<Category, number>(
            {
                query: (id) => ({ url: `/category/${id}` }),
                transformResponse: (response: CategoryGetByIdResponse): Category => response,
                providesTags: (result, error, id) => [{ type: 'Category' as const, id }],
            }
        ),
        create: builder.mutation<Category, CategoryCreateRequest>({
            query: (createRequest) => ({ url: '/category/create', method: 'POST', body: createRequest }),
            transformResponse: (response: CategoryCreateResponse): Category => response,
            invalidatesTags: [{ type: 'Category', id: 'LIST' }],
        }),
        update: builder.mutation<Category, { id: number, body: CategoryUpdateRequest }>({
            query: (updateRequest) => ({ url: `/category/${updateRequest.id}/update`, method: 'PUT', body: updateRequest.body }),
            transformResponse: (response: CategoryUpdateResponse): Category => response,
            invalidatesTags: (result, error, updateRequest) => result ? [
                { type: 'Category' as const, id: result.id }, { type: 'Category', id: 'LIST' }]
                : [{ type: 'Category', id: 'LIST' }],
        }),
        delete: builder.mutation<void, number>({
            query: (id) => ({ url: `/category/${id}`, method: 'DELETE' }),
            invalidatesTags: (result, error, id) => error ? [
            ]
                : [{ type: 'Category' as const, id: id },
                { type: 'Category', id: 'LIST' },]
        }),
    }),
    overrideExisting: false,
})

export const { useAllQuery, useFilterQuery, useByIdQuery, useCreateMutation, useUpdateMutation, useDeleteMutation } = categoryApi
