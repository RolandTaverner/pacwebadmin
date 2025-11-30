import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'

const apiUrl = import.meta.env.API_URL;

function getBaseURL(): string {
  if (apiUrl.length != 0) {
    return apiUrl;
  }

  return document.location.origin + '/api';
}

// initialize an empty api service that we'll inject endpoints into later as needed
export const api = createApi({
  baseQuery: fetchBaseQuery({ baseUrl: getBaseURL() }),
  endpoints: () => ({}),
  tagTypes: ['Category', 'Proxy', 'Condition', 'ProxyRule', 'ProxyRuleConditions', 'PAC', 'PACProxyRules'],
})
