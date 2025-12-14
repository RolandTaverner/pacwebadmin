import { useMemo, useState } from 'react';
import './ProxyRules.css';

import type { FetchBaseQueryError } from '@reduxjs/toolkit/query';
import type { SerializedError } from '@reduxjs/toolkit';

import {
  Box,
  Button,
  Checkbox,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  Tooltip,
  Typography
} from '@mui/material';

import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

import type { Row, FilterFn, FilterMeta } from '@tanstack/react-table';
import { filterFns, getFilteredRowModel } from '@tanstack/react-table';

import {
  MRT_EditActionButtons,
  MaterialReactTable,
  type MRT_ColumnDef,
  type MRT_FilterFn,
  type MRT_Row,
  type MRT_TableOptions,
  useMaterialReactTable,
  type DropdownOption,
} from 'material-react-table';

import { useAllProxyRulesQuery, useCreateProxyRuleMutation, useUpdateProxyRuleMutation, useDeleteProxyRuleMutation } from '../../services/proxyrule';
import { useAllProxiesQuery } from '../../services/proxy';
import type { ProxyRule, ProxyRuleCreateRequest, ProxyRuleUpdateRequest, Proxy } from "../../services/types";
import { MutationError, getErrorMessage } from '../errors/errors';
import ConditionSelector from './ConditionSelector';
import CheckboxEdit from '../common/CheckboxEdit';
import ProxyCell, { displayProxyString } from '../common/ProxyCell';

class RowData {
  id: number;
  name: string;
  enabled?: boolean;
  proxy?: Proxy;
  proxyId?: number;
  displayProxyString?: string;
  conditionIds?: number[];

  constructor(id: number, name: string, enabled?: boolean, proxy?: Proxy, conditionIds?: number[]) {
    this.id = id;
    this.name = name;
    this.enabled = enabled;
    this.proxy = proxy;
    this.proxyId = proxy?.id;
    this.displayProxyString = displayProxyString(proxy);
    this.conditionIds = conditionIds;
  }
}

function RowDataFromProxyRule(p: ProxyRule): RowData {
  return new RowData(p.id, p.name, p.enabled, p.proxy, p.conditions.map(c => c.id));
}

function proxyFilterFn(row: Row<RowData>, columnId: string, filterValue: any, addMeta: (meta: FilterMeta) => void): boolean {
  console.debug("proxyFilterFn", columnId, filterValue);

  if (row.original.displayProxyString == null) {
    return false;
  }

  return row.original.displayProxyString.toLowerCase().includes(filterValue.toLowerCase());
}

const customGlobalFilter: FilterFn<RowData> = (row: Row<RowData>, columnId: string, filterValue: string, addMeta: (meta: FilterMeta) => void) => {
  console.debug("customGlobalFilter", columnId, filterValue);
  const customFilterFn = row
    .getVisibleCells()
    .find((c) => c.column.id === columnId)
    ?.column.getFilterFn();

  if (typeof customFilterFn === "function") {
    return customFilterFn(row as Row<RowData>, columnId, filterValue, addMeta);
  }

  return filterFns.includesString(row as Row<RowData>, columnId, filterValue, addMeta);
};

function ProxyRules() {
  console.debug("=================== ProxyRules");

  const { data: proxyrules = [], isFetching: isFetchingProxyRules, isError: isFetchingProxyRulesError } = useAllProxyRulesQuery();
  const { data: proxies = [], isFetching: isFetchingProxies, isError: isFetchingProxiesError } = useAllProxiesQuery();

  const [validationErrors, setValidationErrors] = useState<Record<string, string | undefined>>({});
  const [mutationError, setMutationError] = useState<FetchBaseQueryError | SerializedError | undefined>(undefined);

  // call CREATE hook
  const [createProxyRule, createProxyRuleResult] = useCreateProxyRuleMutation()
  // call UPDATE hook
  const [updateProxyRule, updateProxyRuleResult] = useUpdateProxyRuleMutation()
  // call DELETE hook
  const [deleteProxyRule, deleteProxyRuleResult] = useDeleteProxyRuleMutation()

  const rowsData = useMemo<RowData[]>(() => proxyrules.map(p => RowDataFromProxyRule(p)), [proxyrules]);
  const proxiesSelectData = useMemo<DropdownOption[]>(() => proxies.map(p => (
    {
      label: displayProxyString(p),
      value: p.id
    })), [proxies]);

  const columns = useMemo<MRT_ColumnDef<RowData>[]>(
    () => [
      {
        accessorKey: 'id',
        header: 'Id',
        enableEditing: false,
        maxSize: 50,
      },
      {
        accessorKey: 'name',
        header: 'Name',
        size: 200,
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.name,
          helperText: validationErrors?.name,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              name: undefined,
            }),
          // optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'enabled',
        header: 'Enabled',
        size: 120,
        Cell: ({ cell }) => (
          <Checkbox checked={cell.row.original.enabled} disabled name='enabled' />
        ),
        Edit: ({ cell, column, row, table }) => {
          const onChange = (checked: boolean) => {
            console.log('Edit.onChange()', checked);
            row._valuesCache[column.id] = checked;
          };
          const checkedInitial: boolean = cell.row.original.enabled ? cell.row.original.enabled : false;
          return <CheckboxEdit required={true} label='Enabled' checkedInitial={checkedInitial} onChange={onChange} />
        },
      },
      {
        accessorKey: 'proxyId',
        Cell: ({ row }) => (
          <ProxyCell proxy={row.original.proxy} maxWidth={500} />
        ),
        header: 'Proxy',
        size: 300,
        editVariant: 'select',
        editSelectOptions: proxiesSelectData,
        muiEditTextFieldProps: {
          required: true,
        },
        filterFn: proxyFilterFn,
      },
    ],
    [validationErrors, proxiesSelectData],
  );

  // CREATE action
  const handleCreateProxyRule: MRT_TableOptions<RowData>['onCreatingRowSave'] = async ({
    values,
    table,
  }) => {
    console.debug("handleCreateProxyRule");

    const newValidationErrors = validateProxyRule(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const createRequest: ProxyRuleCreateRequest = { name: values.name, enabled: values.enabled, proxyId: values.proxyId, conditionIds: values.conditionIds };

    await createProxyRule(createRequest).unwrap()
      .then((value: ProxyRule) => {
        // TODO: use value to update row
        table.setCreatingRow(null); // exit creating mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('createProxyRule()', error)
      });
  };

  // UPDATE action
  const handleSaveProxyRule: MRT_TableOptions<RowData>['onEditingRowSave'] = async ({
    values,
    table,
  }) => {
    console.debug("handleSaveProxyRule");

    const newValidationErrors = validateProxyRule(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const updateRequestBody: ProxyRuleUpdateRequest = { name: values.name, enabled: values.enabled, proxyId: values.proxyId, conditionIds: values.conditionIds };
    const updateRequest = { id: values.id, body: updateRequestBody }

    await updateProxyRule(updateRequest).unwrap()
      .then((value: ProxyRule) => {
        // TODO: use value to update row
        table.setEditingRow(null); // exit editing mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('updateProxyRule()', error)
      });
  };

  // DELETE action
  const openDeleteConfirmModal = (row: MRT_Row<RowData>) => {
    if (window.confirm('Are you sure you want to delete this proxyrule?')) {
      deleteProxyRule(row.original.id).unwrap().catch((error) => {
        window.alert(getErrorMessage(error));
        console.error('deleteProxyRule()', error)
      });
    }
  };

  const table = useMaterialReactTable({
    columns,
    layoutMode: 'grid-no-grow',
    displayColumnDefOptions: {
      'mrt-row-actions': {
        size: 90,
      },
    },
    data: rowsData,
    createDisplayMode: 'modal', // default ('row', and 'custom' are also available)
    editDisplayMode: 'modal', // default ('row', 'cell', 'table', and 'custom' are also available)
    enableEditing: true,
    getRowId: (row, index, parent) => { let id = row?.id ? row.id.toString() : 'idx' + index.toString(); return id; },
    muiToolbarAlertBannerProps: isFetchingProxyRulesError
      ? {
        color: 'error',
        children: 'Error loading data',
      }
      : undefined,
    muiTableContainerProps: {
      sx: {
        minHeight: '500px',
      },
    },
    muiEditRowDialogProps: {
      open: true,
      maxWidth: 'md',
    },
    muiCreateRowModalProps: {
      open: true,
      maxWidth: 'md',
    },
    onCreatingRowCancel: () => { setValidationErrors({}); /*setMutationError(undefined); */ },
    onCreatingRowSave: handleCreateProxyRule,
    onEditingRowCancel: () => { setValidationErrors({}); /* setMutationError(undefined); */ },
    onEditingRowSave: handleSaveProxyRule,
    renderCreateRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4" >Create new ProxyRule</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {internalEditComponents}
          <Typography variant="h6" sx={{ mt: 2 }}>Conditions</Typography>
          <ConditionSelector
            conditionIds={row.original.conditionIds ? row.original.conditionIds : []}
            onSelectionChange={(ids) => {
              console.debug("onSelectionChange", ids);
              row._valuesCache.conditionIds = ids;
            }}
          />
          {MutationError(mutationError)}
        </DialogContent>
        <DialogActions>
          <MRT_EditActionButtons variant="text" table={table} row={row} />
        </DialogActions>
      </>
    ),
    renderEditRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4">Edit ProxyRule</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
          {internalEditComponents}
          <Typography variant="h6" sx={{ mt: 2 }}>Conditions</Typography>
          <ConditionSelector
            conditionIds={row.original.conditionIds ? row.original.conditionIds : []}
            onSelectionChange={(ids) => {
              row._valuesCache.conditionIds = ids;
            }}
          />
          {MutationError(mutationError)}
        </DialogContent>
        <DialogActions>
          <MRT_EditActionButtons variant="text" table={table} row={row} />
        </DialogActions>
      </>
    ),
    renderRowActions: ({ row, table }) => (
      <Box sx={{ display: 'flex', gap: '1rem' }}>
        <Tooltip title="Edit">
          <IconButton onClick={() => table.setEditingRow(row)}>
            <EditIcon />
          </IconButton>
        </Tooltip>
        <Tooltip title="Delete">
          <IconButton color="error" onClick={() => openDeleteConfirmModal(row)}>
            <DeleteIcon />
          </IconButton>
        </Tooltip>
      </Box>
    ),
    renderTopToolbarCustomActions: ({ table }) => (
      <Button
        variant="contained"
        onClick={() => {
          table.setCreatingRow(true);
        }}
      >
        Create new ProxyRule
      </Button>
    ),
    filterFns: {
      customGlobalFilter: customGlobalFilter,
    },
    globalFilterFn: 'customGlobalFilter',
    getFilteredRowModel: getFilteredRowModel(),
    manualFiltering: false,
    state: {
      isLoading: isFetchingProxyRules || isFetchingProxies,
      isSaving: createProxyRuleResult.isLoading || updateProxyRuleResult.isLoading || deleteProxyRuleResult.isLoading,
      showAlertBanner: isFetchingProxyRulesError,
      showProgressBars: isFetchingProxyRules || isFetchingProxies,
    },
  });

  return (
    <>
      <Box sx={{ bgcolor: 'primary.dark' }}>
        <MaterialReactTable table={table} />
      </Box>
    </>
  )
}

const validateRequired = (value?: string) => value != null && !!value.length;

function validateProxyRule(c: RowData) {
  return {
    name: !validateRequired(c.name) ? 'Name is Required' : '',
  };
}

export default ProxyRules;
