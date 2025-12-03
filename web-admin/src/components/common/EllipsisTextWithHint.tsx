import React from 'react';
import { Typography, Tooltip } from '@mui/material';

const EllipsisTextWithHint: React.FC<{
  longText: string | undefined;
  maxWidth: string | number | undefined
}> = ({ longText, maxWidth }) => {
  return (
    <Tooltip title={longText}>
      <Typography noWrap style={{ maxWidth: maxWidth }}>
        {longText}
      </Typography>
    </Tooltip>
  );
};

export default EllipsisTextWithHint;
