import React, { useState } from 'react';

import {
  Button,
  Checkbox,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
} from '@mui/material';

import { MaterialReactTable, type MRT_ColumnDef } from 'material-react-table';
import type { Updater, RowSelectionState } from '@tanstack/react-table';

import type { ProxyRule } from '../../services/types';
import { displayProxyString } from '../common/ProxyCell';

interface ProxyRuleSelectorState {
  state: RowSelectionState;
  selectedProxyRuleIds: number[];
}

class RowData {
  id: number;
  name: string;
  enabled?: boolean;
  proxyTypeAddress?: string;

  constructor(id: number, name: string, enabled?: boolean, proxyTypeAddress?: string) {
    this.id = id;
    this.name = name;
    this.enabled = enabled;
    this.proxyTypeAddress = proxyTypeAddress;
  }
}

function RowDataFromProxyRule(p: ProxyRule): RowData {
  return new RowData(p.id, p.name, p.enabled, displayProxyString(p.proxy));
}

const ProxyRuleSelectorDialog: React.FC<{
  open: boolean;
  onClose: (selectedIds: number[]) => void;
  initialSelected: number[];
  allProxyRules: ProxyRule[];
}> = ({ open, onClose, initialSelected, allProxyRules }) => {
  console.debug("=================== ProxyRuleSelectorDialog");

  const [selection, setSelection] = useState<ProxyRuleSelectorState>({ state: {}, selectedProxyRuleIds: [] });
  const initialSelectedValidated = initialSelected ? initialSelected : [];
  const availableProxyRules = allProxyRules.filter(
    (pr) => !initialSelectedValidated.includes(pr.id)
  );

  const rowsData = availableProxyRules.map(p => RowDataFromProxyRule(p));

  const columns: MRT_ColumnDef<RowData>[] = [
    {
      accessorKey: 'id',
      header: 'ID',
      maxSize: 60,
    },
    {
      accessorKey: 'name',
      header: 'Name'
    },
    {
      accessorKey: 'enabled',
      header: 'Enabled',
      maxSize: 100,
      Cell: ({ cell }) => (
        <Checkbox checked={cell.row.original.enabled} disabled />
      ),
    },
    {
      accessorKey: 'proxyTypeAddress',
      header: 'Proxy'
    },
  ];

  return (
    <Dialog open={open} onClose={() => onClose(initialSelectedValidated)} maxWidth="md" fullWidth>
      <DialogTitle>Add Proxy rules</DialogTitle>
      <DialogContent>
        <MaterialReactTable
          columns={columns}
          data={rowsData}
          enableRowSelection
          enableMultiRowSelection
          getRowId={(row) => row.id.toString()}
          state={{ rowSelection: selection.state }}
          onRowSelectionChange={(getNewState: Updater<RowSelectionState>) => {
            const newState = typeof getNewState === 'function' ? getNewState(selection.state) : getNewState;
            const selectedProxyRuleIds = availableProxyRules.filter(c => newState[c.id]).map(c => c.id);
            console.debug("onRowSelectionChange(): selectedProxyRuleIds", selectedProxyRuleIds);

            setSelection({ state: newState, selectedProxyRuleIds: selectedProxyRuleIds })
          }}
          muiTableContainerProps={{ sx: { maxHeight: '600px' } }}
        />
      </DialogContent>

      <DialogActions>
        <Button onClick={() => onClose(initialSelectedValidated)}>Cancel</Button>
        <Button
          onClick={() => {
            console.debug("OK onClick()", [...initialSelectedValidated, ...selection.selectedProxyRuleIds]);
            onClose([...initialSelectedValidated, ...selection.selectedProxyRuleIds])
          }}
          variant="contained"
        >
          OK
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ProxyRuleSelectorDialog;