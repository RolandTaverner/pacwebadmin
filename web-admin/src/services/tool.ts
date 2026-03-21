import { api } from './api';

import type {
  ToolQuickAddConditionsRequest, ToolQuickAddConditionsResponse,
} from './types';

const toolApi = api.injectEndpoints({
  endpoints: (builder) => ({
    quickAddConditions: builder.mutation<ToolQuickAddConditionsResponse, ToolQuickAddConditionsRequest>({
      query: (request) => ({ url: '/tool/quick_add_conditions', method: 'POST', body: request }),
      invalidatesTags: (result, error, request) => error ? [] : [
        { type: 'Condition', id: 'LIST' },
        { type: 'ProxyRule', id: request.proxyRuleId },
        { type: 'PAC' },
        { type: 'PACPreview' },
      ],
    }),
  }),
  overrideExisting: false,
})

export const { useQuickAddConditionsMutation } = toolApi;
