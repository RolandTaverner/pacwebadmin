import { api } from './api'

import type { Category, CategoryAllResponse, CategoryGetByIdResponse } from './types'

const categoryApi = api.injectEndpoints({
    endpoints: (builder) => ({
        all: builder.query<Category[], void>(
            {
                query: () => ({ url: '/category/all' }),
                transformResponse: (response: CategoryAllResponse): Category[] => response.categories,
                providesTags: (result, error) => result
                    ? [
                        ...result.map(({ id }) => ({ type: 'Category' as const, id })),
                        { type: 'Category', id: 'LIST' },
                    ]
                    : [{ type: 'Category', id: 'LIST' }],

            }
        ),
        byId: builder.query<Category, number>(
            {
                query: (id) => ({ url: `/category/${id}` }),
                transformResponse: (response: CategoryGetByIdResponse): Category => response,
                providesTags: (result, error, id: number) => [{ type: 'Category', id }],
            }

        ),
    }),
    overrideExisting: false,
})

export const { useAllQuery, useByIdQuery } = categoryApi
