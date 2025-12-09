import { configureStore } from '@reduxjs/toolkit';
import { api } from '../services/api';
import authReducer from './slices/auth';

export const store = configureStore({
  reducer: {
    [api.reducerPath]: api.reducer, // Add the generated reducer as a specific top-level slice
    auth: authReducer,
  },
  // Adding the api middleware enables caching, invalidation, polling,
  // and other useful features of `rtk-query`.
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(api.middleware),
})

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

export default store;
