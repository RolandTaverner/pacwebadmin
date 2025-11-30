import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'


function getBaseURL(): string {
  return 'http://127.0.0.1:8080/api';
}

// initialize an empty api service that we'll inject endpoints into later as needed
export const api = createApi({
  baseQuery: fetchBaseQuery({ baseUrl: getBaseURL() }),
  endpoints: () => ({}),
  tagTypes: ['Category', 'Proxy', 'Condition', 'ProxyRule', 'ProxyRuleConditions', 'PAC', 'PACProxyRules'],
})
