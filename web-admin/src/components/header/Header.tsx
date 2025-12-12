import './Header.css';

import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Typography, Button, Box } from '@mui/material';
import Container from '@mui/material/Container';

import { type RootState } from '../../redux/store';
import { logoutUser } from '../../redux/slices/user';
import { useUserProfileQuery, useLogoutUserMutation } from '../../services/user';

const Header: React.FC<{}> = ({ }) => {
  const dispatch = useDispatch();
  const token = useSelector((state: RootState) => state.user.token);
  const { data: profileResponse } = useUserProfileQuery();
  const [logoutUserMutation] = useLogoutUserMutation();

  const authorized = token && profileResponse?.userName;

  const handleLogout = async () => {
    try {
      await logoutUserMutation().unwrap();
    } catch (error) {
      // Ignore API errors during logout
    } finally {
      dispatch(logoutUser());
    }
  };

  return (
    <Container sx={{ position: "relative", bgcolor: 'primary.light', display: 'flex', height: 40, width: 1500, justifyContent: 'space-between', alignItems: 'center' }} maxWidth={false} >
      <Typography color="#FFFFFF" variant="h5">
        PAC web admin
      </Typography>
      {authorized && (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Typography color="#FFFFFF" variant="body1">
            {profileResponse.userName}
          </Typography>
          <Button 
            variant="outlined" 
            color="inherit" 
            size="small"
            onClick={handleLogout}
            sx={{ color: '#FFFFFF', borderColor: '#FFFFFF' }}
          >
            Logout
          </Button>
        </Box>
      )}
    </Container>
  )
};

export default Header;
