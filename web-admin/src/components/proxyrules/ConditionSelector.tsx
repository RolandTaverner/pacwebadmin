import React, { useState } from 'react';

import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  Tooltip,
} from '@mui/material';

import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';

import { MaterialReactTable, type MRT_ColumnDef } from 'material-react-table';
import type { Updater, RowSelectionState } from '@tanstack/react-table';

import { useAllConditionsQuery } from '../../services/condition';
import type { Condition } from '../../services/types';

interface ConditionSelectorProps {
  conditionIds: number[];
  onSelectionChange: (ids: number[]) => void;
}

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

const ConditionSelector: React.FC<ConditionSelectorProps> = ({
  conditionIds,
  onSelectionChange,
}) => {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const { data: allConditions = [], isLoading } = useAllConditionsQuery();
  const [selectedConditionIds, setSelectedConditionIds] = useState<number[]>(conditionIds ? conditionIds : []);

  const selectedConditions = allConditions.filter(condition =>
    selectedConditionIds ? selectedConditionIds.includes(condition.id) : false
  );

  const columns: MRT_ColumnDef<Condition>[] = [
    { accessorKey: 'type', header: 'Type' },
    { accessorKey: 'expression', header: 'Expression' },
    { accessorKey: 'category.name', header: 'Category' },
  ];

  return (
    <div>
      <MaterialReactTable
        columns={columns}
        data={selectedConditions}
        enableRowActions
        positionActionsColumn="last"
        renderRowActions={({ row }) => (
          <Tooltip title="Remove condition">
            <IconButton
              color="error"
              onClick={() => {
                const newSelected = selectedConditionIds.filter(
                  id => id !== row.original.id
                );
                setSelectedConditionIds(newSelected);
                onSelectionChange(newSelected);
              }}
            >
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        )}
        renderTopToolbarCustomActions={() => (
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            onClick={() => setIsDialogOpen(true)}
          >
            Add Condition
          </Button>
        )}
        muiTableContainerProps={{ sx: { maxHeight: '500px', minHeight: '300px' } }}
        state={{ isLoading }}
      />

      <ConditionSelectorDialog
        open={isDialogOpen}
        onClose={(selectedIds) => {
          setIsDialogOpen(false);
          if (selectedIds !== conditionIds) {
            setSelectedConditionIds(selectedIds);
            onSelectionChange(selectedIds);
          }
        }}
        initialSelected={conditionIds}
        allConditions={allConditions}
      />
    </div>
  );
};

export default ConditionSelector;