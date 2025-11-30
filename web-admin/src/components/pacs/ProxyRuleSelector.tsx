import React, { useState } from 'react';

import {
  Button,
  IconButton,
  Tooltip,
} from '@mui/material';

import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';

import { MaterialReactTable, type MRT_ColumnDef } from 'material-react-table';

import { useAllProxyRulesQuery } from '../../services/proxyrule';
import type { ProxyRuleIdWithPriority } from '../../services/types';

import ProxyRuleSelectorDialog from './ProxyRuleSelectorDialog';

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
  console.debug("=================== ProxyRuleSelector");

  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const { data: allProxyRules = [], isLoading } = useAllProxyRulesQuery();
  const [selectedProxyRules, setSelectedProxyRules] = useState<ProxyRuleIdWithPriority[]>(proxyRuleIdsWithPriority ? proxyRuleIdsWithPriority : []);

  const rows = selectedProxyRules.map(prp => ({ proxyRule: allProxyRules.find(pr => pr.id == prp.proxyRuleId), priority: prp.priority }))
    .filter(i => i.proxyRule != null)
    .sort((a, b) => {
      if (a.priority != b.priority) return a.priority - b.priority;
      return (a.proxyRule ? a.proxyRule.id : 0) - (b.proxyRule ? b.proxyRule.id : 0);
    })
    .map<RowData>(i => ({
      proxyRuleId: i.proxyRule?.id,
      proxyRuleName: i.proxyRule?.name,
      proxyRuleProxy: i.proxyRule?.proxy.type + ' ' + i.proxyRule?.proxy.address,
      priority: i.priority,
    }));


  const columns: MRT_ColumnDef<RowData>[] = [
    { accessorKey: 'proxyRuleId', header: 'Proxy rule ID', maxSize: 100 },
    { accessorKey: 'proxyRuleName', header: 'Name' },
    { accessorKey: 'proxyRuleProxy', header: 'Proxy' },
    { accessorKey: 'priority', header: 'Priority', maxSize: 100 },
  ];

  return (
    <div>
      <MaterialReactTable
        columns={columns}
        data={rows}
        enableRowActions
        positionActionsColumn="first"
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

      <ProxyRuleSelectorDialog
        open={isDialogOpen}
        onClose={(selectedIds) => {
          setIsDialogOpen(false);
          console.debug("onClose() selectedIds", selectedIds);

          let changed = false;
          const withoutUnselected = proxyRuleIdsWithPriority.filter(prp => selectedIds.includes(prp.proxyRuleId));
          console.debug("onClose() withoutUnselected", withoutUnselected);
          changed = changed || withoutUnselected.length != proxyRuleIdsWithPriority.length;

          const withoutUnselectedIds = withoutUnselected.map(prp => prp.proxyRuleId);
          console.debug("onClose() withoutUnselectedIds", withoutUnselectedIds);

          const idsToAdd = selectedIds.filter(id => !withoutUnselectedIds.includes(id)).sort((a, b) => a - b);
          changed = changed || idsToAdd.length != 0;

          console.debug("onClose() idsToAdd", idsToAdd);
          let priority = 1;
          if (withoutUnselected.length != 0) {
            priority += Math.max(...withoutUnselected.map(prp => prp.priority))
          }
          const proxyRuleIdsWithPriorityToAdd = idsToAdd.map<ProxyRuleIdWithPriority>(id => ({ proxyRuleId: id, priority: priority++ }));

          console.debug("onClose() changed", changed);

          if (changed) {
            const result = withoutUnselected.concat(proxyRuleIdsWithPriorityToAdd);
            setSelectedProxyRules(result);
            onSelectionChange(result);
          }
        }}
        initialSelected={proxyRuleIdsWithPriority.map(prp => prp.proxyRuleId)}
        allProxyRules={allProxyRules}
      />
    </div>
  );
};

export default ProxyRuleSelector;