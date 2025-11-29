import { api } from './api'

import type {
  Proxy, ProxiesResponse,
  ProxyGetByIdResponse,
  ProxyFilterRequest,
  ProxyCreateRequest, ProxyCreateResponse,
  ProxyUpdateRequest, ProxyUpdateResponse
} from './types'

const proxyApi = api.injectEndpoints({
  endpoints: (builder) => ({
    allProxies: builder.query<Proxy[], void>(
      {
        query: () => ({ url: '/proxy/list' }),
        transformResponse: (response: ProxiesResponse): Proxy[] => response.proxies,
        providesTags: (result, error) => result
          ? [
            ...result.map(({ id }) => ({ type: 'Proxy' as const, id })),
            { type: 'Proxy' as const, id: 'LIST' },
          ]
          : [{ type: 'Proxy' as const, id: 'LIST' }],

      }
    ),
    filterProxies: builder.query<Proxy[], ProxyFilterRequest>(
      {
        query: (filter) => ({ url: '/proxy/filter', method: 'POST', body: filter }),
        transformResponse: (response: ProxiesResponse): Proxy[] => response.proxies,
        providesTags: (result, error, filter) => result
          ? [...result.map(({ id }) => ({ type: 'Proxy' as const, id })), { type: 'Proxy' as const, id: 'LIST' }]
          : [{ type: 'Proxy' as const, id: 'LIST' }],
      }
    ),
    byIdProxy: builder.query<Proxy, number>(
      {
        query: (id) => ({ url: `/proxy/list/${id}` }),
        transformResponse: (response: ProxyGetByIdResponse): Proxy => response,
        providesTags: (result, error, id) => [{ type: 'Proxy' as const, id }],
      }
    ),
    createProxy: builder.mutation<Proxy, ProxyCreateRequest>({
      query: (createRequest) => ({ url: '/proxy/list', method: 'POST', body: createRequest }),
      transformResponse: (response: ProxyCreateResponse): Proxy => response,
      invalidatesTags: [{ type: 'Proxy' as const, id: 'LIST' }],
    }),
    updateProxy: builder.mutation<Proxy, { id: number, body: ProxyUpdateRequest }>({
      query: (updateRequest) => ({ url: `/proxy/list/${updateRequest.id}`, method: 'PUT', body: updateRequest.body }),
      transformResponse: (response: ProxyUpdateResponse): Proxy => response,
      invalidatesTags: (result, error, updateRequest) => result ? [
        { type: 'Proxy' as const, id: result.id }, { type: 'Proxy' as const, id: 'LIST' }]
        : [{ type: 'Proxy' as const, id: 'LIST' }],
    }),
    deleteProxy: builder.mutation<void, number>({
      query: (id) => ({ url: `/proxy/list/${id}`, method: 'DELETE' }),
      invalidatesTags: (result, error, id) => error ? []
        : [{ type: 'Proxy' as const, id },
        { type: 'Proxy' as const, id: 'LIST' }]
    }),
  }),
  overrideExisting: false,
})

export const { useAllProxiesQuery, useFilterProxiesQuery, useByIdProxyQuery, useCreateProxyMutation, useUpdateProxyMutation, useDeleteProxyMutation } = proxyApi
