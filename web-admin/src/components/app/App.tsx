import { useEffect } from 'react';
import { useSelector } from 'react-redux';
import './App.css';

import { useUserProfileQuery } from '../../services/user';
import type { RootState } from '../../redux/store';

import Header from '../header/Header';
import Admin from '../admin/Admin';
import Login from '../login/Login';

function App() {
  console.debug("=================== App");

  const token = useSelector((state: RootState) => state.user.token);
  const { data: profileResponse, isFetching: isFetchingProfile, isError: isFetchingProfileError, refetch } = useUserProfileQuery();
  const authorized = token && !isFetchingProfileError
    && profileResponse != null && profileResponse.userName && profileResponse.userName.length > 0;

  useEffect(() => {
    if (token) {
      refetch();
    }
  }, [token, refetch]);

  if (isFetchingProfile) {
    return (
      <>
        <Header />
        <div>Loading...</div>
      </>
    );
  }

  return (
    <>
      <Header />
      {authorized ? <Admin /> : <Login />}
    </>
  )
}

export default App;
