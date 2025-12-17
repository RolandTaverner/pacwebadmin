import './Dashboard.css';

import React from 'react';
import { Box } from '@mui/material';

import PACBoard from './pac/PACBoard';

const Dashboard: React.FC<{}> = ({ }) => {
  console.debug("=================== Dashboard");

  return (
    <Box sx={{ display: 'display-box' }}>
      <PACBoard />
    </Box>
  )
};

export default Dashboard;
