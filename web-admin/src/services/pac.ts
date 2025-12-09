import { api } from './api';

import type {
  PAC, PACsResponse,
  PACGetByIdResponse,
  PACCreateRequest, PACCreateResponse,
  PACUpdateRequest, PACUpdateResponse,
  ProxyRuleWithPriority,
  PACProxyRulesResponse,
  PACProxyRuleAddRequest, PACProxyRuleAddResponse,
  PACProxyRuleRemoveRequest, PACProxyRuleRemoveResponse
} from './types';

const pacApi = api.injectEndpoints({
  endpoints: (builder) => ({
    allPACs: builder.query<PAC[], void>({
      query: () => ({ url: '/pac/list' }),
      transformResponse: (response: PACsResponse): PAC[] => response.pacs,
      providesTags: (result) =>
        result
          ? [
            ...result.map(({ id }) => ({ type: 'PAC' as const, id })),
            { type: 'PAC' as const, id: 'LIST' },
          ]
          : [{ type: 'PAC' as const, id: 'LIST' }],
    }),
    byIdPAC: builder.query<PAC, number>({
      query: (id) => ({ url: `/pac/list/${id}` }),
      transformResponse: (response: PACGetByIdResponse): PAC => response,
      providesTags: (result, error, id) => [{ type: 'PAC' as const, id }],
    }),
    createPAC: builder.mutation<PAC, PACCreateRequest>({
      query: (createRequest) => ({
        url: '/pac/list', method: 'POST', body: createRequest,
      }),
      transformResponse: (response: PACCreateResponse): PAC => response,
      invalidatesTags: [{ type: 'PAC' as const, id: 'LIST' }],
    }),
    updatePAC: builder.mutation<PAC, { id: number; body: PACUpdateRequest }>({
      query: ({ id, body }) => ({ url: `/pac/list/${id}`, method: 'PUT', body: body }),
      transformResponse: (response: PACUpdateResponse): PAC => response,
      invalidatesTags: (result, error, updateRequest) => result ? [
        { type: 'PAC' as const, id: result.id }, { type: 'PAC' as const, id: 'LIST' }]
        : [{ type: 'PAC' as const, id: 'LIST' }],
    }),
    deletePAC: builder.mutation<void, number>({
      query: (id) => ({ url: `/pac/list/${id}`, method: 'DELETE' }),
      invalidatesTags: (result, error, id) => error ? []
        : [{ type: 'PAC' as const, id },
        { type: 'PAC' as const, id: 'LIST' }]
    }),
    pacProxyRules: builder.query<ProxyRuleWithPriority[], number>({
      query: (id) => ({ url: `/pac/list/${id}/rules` }),
      transformResponse: (response: PACProxyRulesResponse): ProxyRuleWithPriority[] => response.proxyRules,
      providesTags: (result, error, id) => error ? [] : [{ type: 'PACProxyRules' as const, id }],
    }),
    pacProxyRulesAdd: builder.mutation<ProxyRuleWithPriority[], PACProxyRuleAddRequest>({
      query: (createRequest) => ({ url: `/pac/list/${createRequest.id}/proxyrules/${createRequest.proxyRuleId}?priority=${createRequest.priority}`, method: 'POST' }),
      transformResponse: (response: PACProxyRuleAddResponse): ProxyRuleWithPriority[] => response.proxyRules,
      invalidatesTags: (result, error, request) => error ? [] : [{ type: 'PACProxyRules' as const, id: request.id }],
    }),
    pacProxyRulesRemove: builder.mutation<ProxyRuleWithPriority[], PACProxyRuleRemoveRequest>({
      query: (removeRequest) => ({ url: `/pac/list/${removeRequest.id}/proxyrules/${removeRequest.proxyRuleId}`, method: 'DELETE' }),
      transformResponse: (response: PACProxyRuleRemoveResponse): ProxyRuleWithPriority[] => response.proxyRules,
      invalidatesTags: (result, error, request) => error ? [] : [{ type: 'PACProxyRules' as const, id: request.id }],
    }),
  }),
  overrideExisting: false,
})

export const {
  useAllPACsQuery,
  useByIdPACQuery,
  useCreatePACMutation,
  useUpdatePACMutation,
  useDeletePACMutation,
  usePacProxyRulesQuery,
  usePacProxyRulesAddMutation,
  usePacProxyRulesRemoveMutation,
} = pacApi
