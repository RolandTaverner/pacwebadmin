import { api } from './api';

import type {
  LoginRequest, LoginResponse, ProfileResponse
} from './types';

const userApi = api.injectEndpoints({
  endpoints: (builder) => ({
    userProfile: builder.query<ProfileResponse, void>(
      {
        query: () => ({ url: '/user/profile' }),
        transformResponse: (response: ProfileResponse): ProfileResponse => response,
        providesTags: (result, error) => [{ type: 'User' as const, id: '' }],
      }
    ),
    loginUser: builder.mutation<LoginResponse, LoginRequest>({
      query: (loginRequest) => (
        {
          url: '/user/login',
          method: 'POST',
          params: { user: loginRequest.user, password: loginRequest.password }
        }),
      invalidatesTags: [{ type: 'User' as const, id: '' }],
    }),
    logoutUser: builder.mutation<void, void>({
      query: () => ({ url: '/user/logout', method: 'POST' }),
      invalidatesTags: [{ type: 'User' as const, id: '' }],
    }),
  }),
  overrideExisting: false,
})

export const { useUserProfileQuery, useLoginUserMutation, useLogoutUserMutation } = userApi;
