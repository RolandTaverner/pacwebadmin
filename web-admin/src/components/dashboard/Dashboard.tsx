import './Dashboard.css';

import React, { useState } from 'react';
import { Box, Button } from '@mui/material';

import PACBoard from './pac/PACBoard';
import QuickAddConditionsDialog from './QuickAddConditionsDialog';

const Dashboard: React.FC<{}> = ({ }) => {
  console.debug("=================== Dashboard");

  const [quickAddOpen, setQuickAddOpen] = useState(false);

  return (
    <Box sx={{ display: 'display-box' }}>
      <Box sx={{ mb: 2, textAlign: 'left' }}>
        <Button variant="contained" onClick={() => setQuickAddOpen(true)}>
          Quick add conditions
        </Button>
      </Box>
      <PACBoard />
      <QuickAddConditionsDialog open={quickAddOpen} onClose={() => setQuickAddOpen(false)} />
    </Box>
  )
};

export default Dashboard;
