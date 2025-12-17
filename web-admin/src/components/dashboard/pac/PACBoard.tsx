import './PACBoard.css';

import React from 'react';

import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';
import { Box, Checkbox, Typography } from '@mui/material';
import Divider from '@mui/material/Divider';
import Accordion from '@mui/material/Accordion';
import AccordionDetails from '@mui/material/AccordionDetails';
import AccordionSummary from '@mui/material/AccordionSummary';
import Alert from '@mui/material/Alert';
import CircularProgress from '@mui/material/CircularProgress';

import { useAllPACsQuery } from '../../../services/pac';
import type { PAC } from "../../../services/types";

const PACBoard: React.FC<{}> = ({ }) => {
  console.debug("=================== PACBoard");
  const { data: pacs = [], isFetching: isFetchingPACs, isError: isFetchingPACsError } = useAllPACsQuery();

  if (isFetchingPACsError) {
    return <Alert severity="error">Error</Alert>;
  }

  return (
    <Box sx={{ display: 'display-box', textAlign: 'left' }}>
      <Typography variant="h5" sx={{ display: 'inline' }}>PACs</Typography>
      <Divider />
      {
        isFetchingPACs ? <CircularProgress /> : pacs.map(p => <PACBoardEntry key={p.id.toString()} pac={p} />)
      }
    </Box>
  )
};

const PACBoardEntry: React.FC<{ pac: PAC }> = ({ pac }) => {
  console.debug("=================== PACBoardEntry ", pac.id, pac.name);

  return (
    <Accordion sx={{ marginTop: '8px' }}>
      <AccordionSummary
        expandIcon={<ArrowDropDownIcon />}
        aria-controls={pac.name}
        id={pac.name}>
        <Typography variant="h5" >{pac.name}</Typography>
      </AccordionSummary>

      <AccordionDetails sx={{ display: 'block' }}>
        <Box display='flex' alignItems="center">
          <Checkbox checked={pac.serve} sx={{ marginRight: '10px' }} />
          <Typography variant='subtitle1' width={'10em'}>Serve path</Typography>
          <Typography>{pac.servePath}</Typography>
        </Box>
        <Divider />

        <Box display='flex' alignItems="center">
          <Checkbox checked={pac.saveToFS} sx={{ marginRight: '10px' }} />
          <Typography variant='subtitle1' width={'10em'}>Save path</Typography>
          <Typography>{pac.saveToFSPath}</Typography>
        </Box>
        <Divider />

        <Typography variant='h6'>Fallback proxy</Typography>
        <Box paddingLeft='1em'>
          <Box display='flex' alignItems="center">
            <Typography variant='subtitle1' width={'10em'}>Description</Typography>
            <Typography>{pac.fallbackProxy.description}</Typography>
          </Box>
          <Box display='flex' alignItems="center">
            <Typography variant='subtitle1' width={'10em'}>Type</Typography>
            <Typography>{pac.fallbackProxy.type}</Typography>
          </Box>
          <Box display='flex' alignItems="center">
            <Typography variant='subtitle1' width={'10em'}>Address</Typography>
            <Typography>{pac.fallbackProxy.address}</Typography>
          </Box>
        </Box>
        <Divider />

      </AccordionDetails>
    </Accordion>
  );
}

export default PACBoard;
