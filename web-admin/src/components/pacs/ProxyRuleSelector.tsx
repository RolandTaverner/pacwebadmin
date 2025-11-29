import React, { useMemo, useState } from 'react';

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

  const rows = proxyRuleIdsWithPriority.map(prp => ({ proxyRule: allProxyRules.find(pr => pr.id == prp.proxyRuleId), priority: prp.priority }))
    .filter(i => i.proxyRule != null)
    .map<RowData>(i => ({
      proxyRuleId: i.proxyRule?.id,
      proxyRuleName: i.proxyRule?.name,
      proxyRuleProxy: i.proxyRule?.proxy.type + ' ' + i.proxyRule?.proxy.address,
      priority: i.priority,
    }));


  const columns: MRT_ColumnDef<RowData>[] = [
    { accessorKey: 'proxyRuleId', header: 'Proxy rule ID' },
    { accessorKey: 'proxyRuleName', header: 'Name' },
    { accessorKey: 'proxyRuleProxy', header: 'Proxy' },
    { accessorKey: 'priority', header: 'Priority' },
  ];

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

      <ProxyRuleSelectorDialog
        open={isDialogOpen}
        onClose={(selectedIds) => {
          setIsDialogOpen(false);
          // if (selectedIds !== proxyRuleIdsWithPriority) {
          //   setSelectedProxyRules(selectedIds);
          //   onSelectionChange(selectedIds);
          // }
        }}
        initialSelected={proxyRuleIdsWithPriority.map(prp => prp.proxyRuleId)}
        allProxyRules={allProxyRules}
      />
    </div>
  );
};

export default ProxyRuleSelector;