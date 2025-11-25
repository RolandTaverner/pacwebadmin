import { api } from './api'

import type {
    ProxyRule, ProxyRulesResponse,
    ProxyRuleGetByIdResponse,
    ProxyRuleCreateRequest, ProxyRuleCreateResponse,
    ProxyRuleUpdateRequest, ProxyRuleUpdateResponse
} from './types'

const proxyruleApi = api.injectEndpoints({
    endpoints: (builder) => ({
        allProxyRules: builder.query<ProxyRule[], void>(
            {
                query: () => ({ url: '/proxyrule/list' }),
                transformResponse: (response: ProxyRulesResponse): ProxyRule[] => response.proxyRules,
                providesTags: (result, error) => result
                    ? [
                        ...result.map(({ id }) => ({ type: 'ProxyRule' as const, id })),
                        { type: 'ProxyRule' as const, id: 'LIST' },
                    ]
                    : [{ type: 'ProxyRule' as const, id: 'LIST' }],

            }
        ),
        byIdProxyRule: builder.query<ProxyRule, number>(
            {
                query: (id) => ({ url: `/proxyrule/list/${id}` }),
                transformResponse: (response: ProxyRuleGetByIdResponse): ProxyRule => response,
                providesTags: (result, error, id) => [{ type: 'ProxyRule' as const, id }],
            }
        ),
        createProxyRule: builder.mutation<ProxyRule, ProxyRuleCreateRequest>({
            query: (createRequest) => ({ url: '/proxyrule/list', method: 'POST', body: createRequest }),
            transformResponse: (response: ProxyRuleCreateResponse): ProxyRule => response,
            invalidatesTags: [{ type: 'ProxyRule' as const, id: 'LIST' }],
        }),
        updateProxyRule: builder.mutation<ProxyRule, { id: number, body: ProxyRuleUpdateRequest }>({
            query: (updateRequest) => ({ url: `/proxyrule/list/${updateRequest.id}`, method: 'PUT', body: updateRequest.body }),
            transformResponse: (response: ProxyRuleUpdateResponse): ProxyRule => response,
            invalidatesTags: (result, error, updateRequest) => result ? [
                { type: 'ProxyRule' as const, id: result.id }, { type: 'ProxyRule' as const, id: 'LIST' }]
                : [{ type: 'ProxyRule' as const, id: 'LIST' }],
        }),
        deleteProxyRule: builder.mutation<void, number>({
            query: (id) => ({ url: `/proxyrule/list/${id}`, method: 'DELETE' }),
            invalidatesTags: (result, error, id) => error ? [
            ]
                : [{ type: 'ProxyRule' as const, id },
                { type: 'ProxyRule' as const, id: 'LIST' },]
        }),
    }),
    overrideExisting: false,
})

export const { useAllProxyRulesQuery, useByIdProxyRuleQuery, useCreateProxyRuleMutation, useUpdateProxyRuleMutation, useDeleteProxyRuleMutation } = proxyruleApi
