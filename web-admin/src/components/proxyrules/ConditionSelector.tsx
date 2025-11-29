import React, { useState } from 'react';

import {
  Button,
  IconButton,
  Tooltip,
} from '@mui/material';

import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';

import { MaterialReactTable, type MRT_ColumnDef } from 'material-react-table';

import { useAllConditionsQuery } from '../../services/condition';
import type { Condition } from '../../services/types';

import ConditionSelectorDialog from './ConditionSelectorDialog';

interface ConditionSelectorProps {
  conditionIds: number[];
  onSelectionChange: (ids: number[]) => void;
}

const ConditionSelector: React.FC<ConditionSelectorProps> = ({
  conditionIds,
  onSelectionChange,
}) => {
  console.debug("=================== ConditionSelector");

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