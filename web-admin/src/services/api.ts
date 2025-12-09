import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import type  { RootState } from '../redux/store';

const apiUrl = import.meta.env.API_URL;

function getBaseURL(): string {
  if (apiUrl.length != 0) {
    return apiUrl;
  }

  return document.location.origin + '/api';
}

const baseQuery = fetchBaseQuery({
  baseUrl: getBaseURL(),
  prepareHeaders: (headers, { getState }) => {
    const token = (getState() as RootState).auth.token

    // If we have a token set in state, let's assume that we should be passing it.
    if (token) {
      headers.set('Authorization', `Bearer ${token}`)
    }

    return headers
  },
})

// initialize an empty api service that we'll inject endpoints into later as needed
export const api = createApi({
  baseQuery: baseQuery,
  endpoints: () => ({}),
  tagTypes: ['Category', 'Proxy', 'Condition', 'ProxyRule', 'ProxyRuleConditions', 'PAC', 'PACProxyRules', 'User'],
})
