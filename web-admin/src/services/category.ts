import { api } from './api'

import type { CategoryAllResponse, CategoryGetByIdResponse } from './types'

const categoryApi = api.injectEndpoints({
    endpoints: (builder) => ({
        all: builder.query<CategoryAllResponse, string>({
            query: () => ({ url: '/category/all' }),
            //transformResponse: (response) => response.categories,
        }),
        byId: builder.query<CategoryGetByIdResponse, string>({
            query: (id) => ({ url: `/category/${id}` }),
        }),
    }),
    overrideExisting: false,
})

export const { useAllQuery, useByIdQuery } = categoryApi
