import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  token: localStorage.getItem('token'),
};

const userSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    loginUser: (state, action) => {
      localStorage.setItem('token', action.payload.token);
      state.token = action.payload.token;
    },
    logoutUser: (state) => {
      localStorage.removeItem('token');
      state.token = null;
    },
  },
});

export const { loginUser, logoutUser } = userSlice.actions;
export default userSlice.reducer;
