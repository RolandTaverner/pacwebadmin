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
            { type: 'PAC', id: 'LIST' },
          ]
          : [{ type: 'PAC', id: 'LIST' }],
    }),
    byIdPAC: builder.query<PAC, number>({
      query: (id) => ({ url: `/pac/list/${id}` }),
      transformResponse: (response: PACGetByIdResponse): PAC => response,
      providesTags: (result, error, id) => [{ type: 'PAC', id }],
    }),
    createPAC: builder.mutation<PAC, PACCreateRequest>({
      query: (createRequest) => ({
        url: '/pac/list', method: 'POST', body: createRequest,
      }),
      transformResponse: (response: PACCreateResponse): PAC => response,
      invalidatesTags: [{ type: 'PAC', id: 'LIST' }],
    }),
    updatePAC: builder.mutation<PAC, { id: number; body: PACUpdateRequest }>({
      query: ({ id, body }) => ({ url: `/pac/list/${id}`, method: 'PUT', body: body }),
      transformResponse: (response: PACUpdateResponse): PAC => response,
      invalidatesTags: (result, error, updateRequest) => result ? [
        { type: 'PAC', id: result.id }, { type: 'PAC', id: 'LIST' }, { type: 'PACPreview' }]
        : [{ type: 'PAC', id: 'LIST' }],
    }),
    deletePAC: builder.mutation<void, number>({
      query: (id) => ({ url: `/pac/list/${id}`, method: 'DELETE' }),
      invalidatesTags: (result, error, id) => error ? []
        : [{ type: 'PAC', id },
        { type: 'PAC', id: 'LIST' }]
    }),
    pacProxyRules: builder.query<ProxyRuleWithPriority[], number>({
      query: (id) => ({ url: `/pac/list/${id}/rules` }),
      transformResponse: (response: PACProxyRulesResponse): ProxyRuleWithPriority[] => response.proxyRules,
      providesTags: (result, error, id) => error ? [] : [{ type: 'PACProxyRules', id }],
    }),
    pacProxyRulesAdd: builder.mutation<ProxyRuleWithPriority[], PACProxyRuleAddRequest>({
      query: (createRequest) => ({ url: `/pac/list/${createRequest.id}/proxyrules/${createRequest.proxyRuleId}?priority=${createRequest.priority}`, method: 'POST' }),
      transformResponse: (response: PACProxyRuleAddResponse): ProxyRuleWithPriority[] => response.proxyRules,
      invalidatesTags: (result, error, request) => error ? [] : [{ type: 'PACProxyRules', id: request.id }, { type: 'PACPreview' }],
    }),
    pacProxyRulesRemove: builder.mutation<ProxyRuleWithPriority[], PACProxyRuleRemoveRequest>({
      query: (removeRequest) => ({ url: `/pac/list/${removeRequest.id}/proxyrules/${removeRequest.proxyRuleId}`, method: 'DELETE' }),
      transformResponse: (response: PACProxyRuleRemoveResponse): ProxyRuleWithPriority[] => response.proxyRules,
      invalidatesTags: (result, error, request) => error ? [] : [{ type: 'PACProxyRules', id: request.id }, { type: 'PACPreview' }],
    }),
    previewPAC: builder.query<string, string>({
      query: (servePath) => ({ url: `/pac/preview/${servePath}`, responseHandler: 'text' }),
      providesTags: (result, error, servePath) => [{ type: 'PACPreview' }],
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
  usePreviewPACQuery
} = pacApi;
