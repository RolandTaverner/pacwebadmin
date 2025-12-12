import './Login.css';

import React, { useState } from 'react';
import { useDispatch } from 'react-redux';

import {
  Alert,
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  TextField,
} from '@mui/material';

import { loginUser } from '../../redux/slices/user';
import { useLoginUserMutation } from '../../services/user';

const Login: React.FC<{}> = ({ }) => {
  console.debug("=================== Login");

  const dispatch = useDispatch();
  const [loginUserMutation, { isLoading }] = useLoginUserMutation();

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  const handleLogin = (newToken: string) => {
    dispatch(loginUser({ token: newToken }));
  };

  const hashPassword = async (password: string): Promise<string> => {
    const encoder = new TextEncoder();
    const data = encoder.encode(password);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    return hashHex.toLowerCase();
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!username.trim() || !password.trim()) {
      setErrorMessage('User and Password are required');
      return;
    }

    setErrorMessage('');

    try {
      const hashedPassword = await hashPassword(password);
      const response = await loginUserMutation({ user: username, password: hashedPassword }).unwrap();
      handleLogin(response.token);
    } catch (error: any) {
      if (error?.status === 403) {
        setErrorMessage('Invalid user/password');
      } else if (error?.status === 'FETCH_ERROR' || error?.originalStatus === 'FETCH_ERROR') {
        setErrorMessage('Cannot connect to server. Please check your network connection.');
      } else if (error?.status === 'TIMEOUT_ERROR') {
        setErrorMessage('Server is not responding. Please try again later.');
      } else if (!error?.status && (error?.message?.includes('fetch') || error?.message?.includes('network'))) {
        setErrorMessage('Network error. Please check your connection.');
      } else {
        setErrorMessage('Unable to connect to server. Please try again later.');
      }
    }
  };

  const handleUsernameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setUsername(e.target.value);
    setErrorMessage('');
  };

  const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(e.target.value);
    setErrorMessage('');
  };

  return (
    <Dialog open={true} maxWidth="xs" fullWidth>
      <form onSubmit={handleSubmit}>
        <DialogTitle>Login</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="User"
            type="text"
            fullWidth
            variant="outlined"
            value={username}
            onChange={handleUsernameChange}
            disabled={isLoading}
            required
          />
          <TextField
            margin="dense"
            label="Password"
            type="password"
            fullWidth
            variant="outlined"
            value={password}
            onChange={handlePasswordChange}
            disabled={isLoading}
            required
          />
          {errorMessage && (
            <Alert severity="error" sx={{ mt: 2 }}>
              {errorMessage}
            </Alert>
          )}
        </DialogContent>

        <DialogActions>
          <Button type="submit" variant="contained" disabled={isLoading}>
            OK
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};

export default Login;
