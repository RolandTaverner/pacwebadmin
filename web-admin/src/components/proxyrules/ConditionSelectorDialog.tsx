import React, { useState } from 'react';

import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
} from '@mui/material';

import { MaterialReactTable, type MRT_ColumnDef } from 'material-react-table';
import type { Updater, RowSelectionState } from '@tanstack/react-table';

import type { Condition } from '../../services/types';

interface ConditionSelectorState {
  state: RowSelectionState;
  selectedConditionIds: number[];
}

const ConditionSelectorDialog: React.FC<{
  open: boolean;
  onClose: (selectedIds: number[]) => void;
  initialSelected: number[];
  allConditions: Condition[];
}> = ({ open, onClose, initialSelected, allConditions }) => {
  console.debug("=================== ConditionSelectorDialog");

  const [selection, setSelection] = useState<ConditionSelectorState>({ state: {}, selectedConditionIds: [] });
  const initialSelectedValidated = initialSelected ? initialSelected : [];
  const availableConditions = allConditions.filter(
    (condition) => !initialSelectedValidated.includes(condition.id)
  );

  const columns: MRT_ColumnDef<Condition>[] = [
    { accessorKey: 'type', header: 'Type' },
    { accessorKey: 'expression', header: 'Expression' },
    { accessorKey: 'category.name', header: 'Category' },
  ];

  return (
    <Dialog open={open} onClose={() => onClose(initialSelectedValidated)} maxWidth="md" fullWidth>
      <DialogTitle>Add Conditions</DialogTitle>
      <DialogContent>
        <MaterialReactTable
          columns={columns}
          data={availableConditions}
          enableRowSelection
          enableMultiRowSelection
          getRowId={(row) => row.id.toString()}
          state={{ rowSelection: selection.state }}
          onRowSelectionChange={(getNewState: Updater<RowSelectionState>) => {
            const newState = typeof getNewState === 'function' ? getNewState(selection.state) : getNewState;
            const selectedConditionIds = availableConditions.filter(c => newState[c.id]).map(c => c.id);
            console.debug("onRowSelectionChange(): selectedConditionIds", selectedConditionIds);

            setSelection({ state: newState, selectedConditionIds: selectedConditionIds })
          }}
          muiTableContainerProps={{ sx: { maxHeight: '600px' } }}
        />
      </DialogContent>

      <DialogActions>
        <Button onClick={() => onClose(initialSelectedValidated)}>Cancel</Button>
        <Button
          onClick={() => {
            console.debug("OK onClick()", [...initialSelectedValidated, ...selection.selectedConditionIds]);
            onClose([...initialSelectedValidated, ...selection.selectedConditionIds])
          }}
          variant="contained"
        >
          OK
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ConditionSelectorDialog;
