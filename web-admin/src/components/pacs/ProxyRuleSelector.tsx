import React, { useMemo, useState } from 'react';

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

import { useAllProxyRulesQuery } from '../../services/proxyrule';
import type { ProxyRule, ProxyRuleIdWithPriority } from '../../services/types';

interface ProxyRuleSelectorProps {
  proxyRuleIdsWithPriority: ProxyRuleIdWithPriority[];
  onSelectionChange: (proxyRuleIdsWithPriority: ProxyRuleIdWithPriority[]) => void;
}

interface RowData {
  proxyRuleId?: number;
  proxyRuleName?: string;
  proxyRuleProxy: string;
  priority: number;
}

const ProxyRuleSelector: React.FC<ProxyRuleSelectorProps> = ({
  proxyRuleIdsWithPriority,
  onSelectionChange,
}) => {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const { data: allProxyRules = [], isLoading } = useAllProxyRulesQuery();
  const [selectedProxyRules, setSelectedProxyRules] = useState<ProxyRuleIdWithPriority[]>(proxyRuleIdsWithPriority ? proxyRuleIdsWithPriority : []);


  const rows = proxyRuleIdsWithPriority.map(prp => ({ proxyRule: allProxyRules.find(pr => pr.id == prp.proxyRuleId), priority: prp.priority }))
    .filter(i => i.proxyRule != null)
    .map<RowData>(i => ({
      proxyRuleId: i.proxyRule?.id,
      proxyRuleName: i.proxyRule?.name,
      proxyRuleProxy: i.proxyRule?.proxy.type + ' ' + i.proxyRule?.proxy.address,
      priority: i.priority,
    }));


  const columns: MRT_ColumnDef<RowData>[] = useMemo<MRT_ColumnDef<RowData>[]>(
    () => [
      { accessorKey: 'proxyRuleId', header: 'Proxy rule ID' },
      { accessorKey: 'proxyRuleName', header: 'Name' },
      { accessorKey: 'proxyRuleProxy', header: 'Proxy' },
      { accessorKey: 'priority', header: 'Priority' },
    ],
    [selectedProxyRules],
  );

  return (
    <div>
      <MaterialReactTable
        columns={columns}
        data={rows}
        enableRowActions
        positionActionsColumn="last"
        renderRowActions={({ row }) => (
          <Tooltip title="Remove proxy rule">
            <IconButton
              color="error"
              onClick={() => {
                const newSelected = selectedProxyRules.filter(
                  prp => prp.proxyRuleId !== row.original.proxyRuleId
                );
                setSelectedProxyRules(newSelected);
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
            Add proxy rule
          </Button>
        )}
        muiTableContainerProps={{ sx: { maxHeight: '500px', minHeight: '300px' } }}
        state={{ isLoading }}
      />

      {/* <ConditionSelectorDialog
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
      /> */}
    </div>
  );
};

export default ProxyRuleSelector;