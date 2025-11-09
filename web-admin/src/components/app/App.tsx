import { useState } from 'react'
import './App.css'

import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

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
      <Container sx={{ flexGrow: 1, bgcolor: 'primary.light', display: 'flex', height: 30, width: 1000, justifySelf: 'flex-start', verticalAlign: "center" }} >
        Header
      </Container>
      <Box
        sx={{ flexGrow: 1, bgcolor: 'background.paper', display: 'flex', height: 340, width: 1000, justifySelf: 'flex-start' }}
      >
        <Tabs
          orientation="vertical"
          //variant="scrollable"
          value={value}
          onChange={handleChange}
          aria-label="Vertical tabs example"
          sx={{ borderRight: 1, borderColor: 'divider', alignContent: 'flex-start' }}
        >
          <Tab label="Dashboard" {...a11yProps(0)} />
          <Tab label="PAC" {...a11yProps(1)} />
          <Tab label="Proxy rules" {...a11yProps(2)} />
          <Tab label="Hosts" {...a11yProps(3)} />
          <Tab label="Proxies" {...a11yProps(4)} />
          <Tab label="Categories" {...a11yProps(5)} />
          <Tab label="About" {...a11yProps(6)} />
        </Tabs>
        <Box sx={{ flexGrow: 1, bgcolor: 'background.paper', display: 'flex', justifyContent: 'flex-start' }}>
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
            Item Six
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
