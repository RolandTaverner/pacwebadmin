import { useMemo, useState } from 'react';
import './ProxyRules.css';

import type { FetchBaseQueryError } from '@reduxjs/toolkit/query';
import type { SerializedError } from '@reduxjs/toolkit';

import {
  Box,
  Button,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  Tooltip,
} from '@mui/material';

import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

import {
  MRT_EditActionButtons,
  MaterialReactTable,
  // createRow,
  type MRT_ColumnDef,
  type MRT_Row,
  type MRT_TableOptions,
  useMaterialReactTable,
  type DropdownOption,
} from 'material-react-table';

import { useAllProxyRulesQuery, useCreateProxyRuleMutation, useUpdateProxyRuleMutation, useDeleteProxyRuleMutation } from '../../services/proxyrule';
import { useAllProxiesQuery } from '../../services/proxy';
import type { ProxyRule, ProxyRuleCreateRequest, ProxyRuleUpdateRequest, Proxy } from "../../services/types";
import { MutationError, getErrorMessage } from '../errors/errors';

class RowData {
  id: number;
  name: string;
  enabled?: boolean;
  proxy?: Proxy;
  proxyId?: number;
  proxyType?: string;
  proxyAddress?: string;


  constructor(id: number, name: string, enabled?: boolean, proxy?: Proxy) {
    this.id = id;
    this.name = name;
    this.enabled = enabled;
    this.proxy = proxy;
    this.proxyId = proxy?.id;
    this.proxyType = proxy?.type;
    this.proxyAddress = proxy?.address;
  }
}

function RowDataFromProxyRule(p: ProxyRule): RowData {
  return new RowData(p.id, p.name, p.enabled, p.proxy);
}

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
  const proxiesSelectData = useMemo<DropdownOption[]>(() => proxies.map(p => ({ label: p.id + ' ' + p.type + ' ' + p.address, value: p.id })), [proxies]);

  const columns = useMemo<MRT_ColumnDef<RowData>[]>(
    () => [
      {
        accessorKey: 'id',
        header: 'Id',
        enableEditing: false,
        size: 80,
      },
      {
        accessorKey: 'name',
        header: 'Name',
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
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.enabled,
          helperText: validationErrors?.enabled,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              enabled: undefined,
            }),
          // optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'proxyId',
        Cell: ({ row }) => (
          <div>
            {row.original.proxyType + ' ' + row.original.proxyAddress}
          </div>
        ),
        header: 'Proxy',
        editVariant: 'select',
        editSelectOptions: proxiesSelectData,
        muiEditTextFieldProps: {
          required: true,
        },
      },
    ],
    [validationErrors],
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

    const createRequest: ProxyRuleCreateRequest = { name: values.name, enabled: values.enabled, proxyId: values.proxyId, conditionIds: [] };

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

    const updateRequestBody: ProxyRuleUpdateRequest = { name: values.name, enabled: values.enabled, proxyId: values.proxyId };
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
    onCreatingRowCancel: () => { setValidationErrors({}); /*setMutationError(undefined); */ },
    onCreatingRowSave: handleCreateProxyRule,
    onEditingRowCancel: () => { setValidationErrors({}); /* setMutationError(undefined); */ },
    onEditingRowSave: handleSaveProxyRule,
    // optionally customize modal content
    renderCreateRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4">Create new ProxyRule</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {internalEditComponents} {/* or render custom edit components here */}
          {MutationError(mutationError)}
        </DialogContent>
        <DialogActions>
          <MRT_EditActionButtons variant="text" table={table} row={row} />
        </DialogActions>
      </>
    ),
    // optionally customize modal content
    renderEditRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4">Edit ProxyRule</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
          {internalEditComponents} {/* or render custom edit components here */}
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
          table.setCreatingRow(true); // simplest way to open the create row modal with no default values
          // or you can pass in a row object to set default values with the `createRow` helper function
          // table.setCreatingRow(
          //   createRow(table, {
          //     //optionally pass in default values for the new row, useful for nested data or other complex scenarios
          //   }),
          // );
        }}
      >
        Create new ProxyRule
      </Button>
    ),
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
