import { useState } from 'react'
import './Categories.css'

import { useAllQuery } from '../../services/category';

import Box from '@mui/material/Box';

function Categories() {
  const [value, setValue] = useState(0);

  const { data = [], isLoading, isFetching, isError } = useAllQuery();


  return (
    <>
      <Box sx={{ bgcolor: 'primary.dark' }}>
        {data.map((c, i) => (
          <div>{c.id} {c.name}</div>
        ))}
      </Box>
    </>
  )
}

export default Categories
