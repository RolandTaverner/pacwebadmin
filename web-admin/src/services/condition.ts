import { api } from './api';

import type {
  Condition, ConditionsResponse,
  ConditionGetByIdResponse,
  ConditionCreateRequest, ConditionCreateResponse,
  ConditionUpdateRequest, ConditionUpdateResponse
} from './types';

const conditionApi = api.injectEndpoints({
  endpoints: (builder) => ({
    allConditions: builder.query<Condition[], void>(
      {
        query: () => ({ url: '/condition/list' }),
        transformResponse: (response: ConditionsResponse): Condition[] => response.conditions,
        providesTags: (result, error) => result
          ? [
            ...result.map(({ id }) => ({ type: 'Condition' as const, id })),
            { type: 'Condition' as const, id: 'LIST' },
          ]
          : [{ type: 'Condition' as const, id: 'LIST' }],

      }
    ),
    byIdCondition: builder.query<Condition, number>(
      {
        query: (id) => ({ url: `/condition/list/${id}` }),
        transformResponse: (response: ConditionGetByIdResponse): Condition => response,
        providesTags: (result, error, id) => [{ type: 'Condition' as const, id }],
      }
    ),
    createCondition: builder.mutation<Condition, ConditionCreateRequest>({
      query: (createRequest) => ({ url: '/condition/list', method: 'POST', body: createRequest }),
      transformResponse: (response: ConditionCreateResponse): Condition => response,
      invalidatesTags: [{ type: 'Condition' as const, id: 'LIST' }],
    }),
    updateCondition: builder.mutation<Condition, { id: number, body: ConditionUpdateRequest }>({
      query: (updateRequest) => ({ url: `/condition/list/${updateRequest.id}`, method: 'PUT', body: updateRequest.body }),
      transformResponse: (response: ConditionUpdateResponse): Condition => response,
      invalidatesTags: (result, error, updateRequest) => result ? [
        { type: 'Condition' as const, id: result.id }, { type: 'Condition' as const, id: 'LIST' }]
        : [{ type: 'Condition' as const, id: 'LIST' }],
    }),
    deleteCondition: builder.mutation<void, number>({
      query: (id) => ({ url: `/condition/list/${id}`, method: 'DELETE' }),
      invalidatesTags: (result, error, id) => error ? [
      ]
        : [{ type: 'Condition' as const, id },
        { type: 'Condition' as const, id: 'LIST' },]
    }),
  }),
  overrideExisting: false,
})

export const { useAllConditionsQuery, useByIdConditionQuery, useCreateConditionMutation, useUpdateConditionMutation, useDeleteConditionMutation } = conditionApi
