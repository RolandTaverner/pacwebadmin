import { useState } from 'react'
import './App.css'

import Categories from '../categories/Categories';

import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`vertical-tabpanel-${index}`}
      aria-labelledby={`vertical-tab-${index}`}
      {...other}
      style={{ width: '100%' }}
    >
      {value === index && (
        <Box sx={{ p: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
}

function a11yProps(index: number) {
  return {
    id: `simple-tab-${index}`,
    'aria-controls': `simple-tabpanel-${index}`,
  };
}

function App() {
  const [value, setValue] = useState(0);

  const handleChange = (event: React.SyntheticEvent, newValue: number) => {
    setValue(newValue);
  };

  return (
    <>
      <Container sx={{ bgcolor: 'primary.light', display: 'flex', height: 30, width: 1000 }} >
        Header
      </Container>
      <Box sx={{display: 'grid', gridTemplateColumns: '150px auto' }}>

        <Box
          sx={{ flexGrow: 1, bgcolor: 'background.paper' }}
        >
          <Tabs
            orientation="vertical"
            variant="standard"
            value={value}
            onChange={handleChange}
            aria-label="Vertical tabs"
            sx={{ borderRight: 1, borderColor: 'divider' }}
          >
            <Tab label="Dashboard" {...a11yProps(0)} />
            <Tab label="PAC" {...a11yProps(1)} />
            <Tab label="Proxy rules" {...a11yProps(2)} />
            <Tab label="Hosts" {...a11yProps(3)} />
            <Tab label="Proxies" {...a11yProps(4)} />
            <Tab label="Categories" {...a11yProps(5)} />
            <Tab label="About" {...a11yProps(6)} />
          </Tabs>
        </Box>

        <Box sx={{ bgcolor: 'background.paper'}}>
          <TabPanel value={value} index={0}>
            Item One
          </TabPanel>
          <TabPanel value={value} index={1}>
            Item Two
          </TabPanel>
          <TabPanel value={value} index={2}>
            Item Three
          </TabPanel>
          <TabPanel value={value} index={3}>
            Item Four
          </TabPanel>
          <TabPanel value={value} index={4}>
            Item Five
          </TabPanel>
          <TabPanel value={value} index={5}>
            <Categories />
          </TabPanel>
          <TabPanel value={value} index={6}>
            Item Seven
          </TabPanel>
        </Box>

      </Box>
    </>
  )
}

export default App
