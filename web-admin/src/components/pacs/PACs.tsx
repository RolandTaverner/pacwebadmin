import { useMemo, useState } from 'react';
import './PACs.css';

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

import { useAllPACsQuery, useCreatePACMutation, useUpdatePACMutation, useDeletePACMutation } from '../../services/pac';
import { useAllProxiesQuery } from '../../services/proxy';
import type { PAC, PACCreateRequest, PACUpdateRequest, ProxyRuleWithPriority, ProxyRuleIdWithPriority, ProxyRule, Proxy } from "../../services/types";
import { MutationError, getErrorMessage } from '../errors/errors';
import ProxyRuleSelector from './ProxyRuleSelector';


class RowData {
  id: number;
  name: string;
  description: string;
  serve: boolean;
  servePath: string;
  saveToFS: boolean;
  saveToFSPath: string;
  fallBackProxy?: Proxy;
  fallBackProxyId?: number;
  fallBackProxyType?: string;
  fallBackProxyAddress?: string;
  proxyRuleIdsWithPriority?: ProxyRuleIdWithPriority[];

  constructor(
    id: number,
    name: string,
    description: string,
    serve: boolean,
    servePath: string,
    saveToFS: boolean,
    saveToFSPath: string,
    fallBackProxy?: Proxy,
    proxyRuleIdsWithPriority?: ProxyRuleIdWithPriority[]
  ) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.serve = serve;
    this.servePath = servePath;
    this.saveToFS = saveToFS;
    this.saveToFSPath = saveToFSPath;
    this.fallBackProxy = fallBackProxy;
    this.fallBackProxyId = fallBackProxy?.id;
    this.fallBackProxyType = fallBackProxy?.type;
    this.fallBackProxyAddress = fallBackProxy?.address;
    this.proxyRuleIdsWithPriority = proxyRuleIdsWithPriority;
  }
}

function RowDataFromPAC(p: PAC): RowData {
  return new RowData(p.id,
    p.name,
    p.description,
    p.serve, p.servePath,
    p.saveToFS, p.saveToFSPath,
    p.fallbackProxy,
    p.proxyRules.map<ProxyRuleIdWithPriority>(i => ({ proxyRuleId: i.proxyRule.id, priority: i.priority }))
  );
}

function PACs() {
  console.debug("=================== PACs");

  const { data: pacs = [], isFetching: isFetchingPACs, isError: isFetchingPACsError } = useAllPACsQuery();
  const { data: proxies = [], isFetching: isFetchingProxies, isError: isFetchingProxiesError } = useAllProxiesQuery();

  const [validationErrors, setValidationErrors] = useState<Record<string, string | undefined>>({});
  const [mutationError, setMutationError] = useState<FetchBaseQueryError | SerializedError | undefined>(undefined);

  // call CREATE hook
  const [createPAC, createPACResult] = useCreatePACMutation()
  // call UPDATE hook
  const [updatePAC, updatePACResult] = useUpdatePACMutation()
  // call DELETE hook
  const [deletePAC, deletePACResult] = useDeletePACMutation()

  const rowsData = useMemo<RowData[]>(() => pacs.map(p => RowDataFromPAC(p)), [pacs]);
  const proxiesSelectData = useMemo<DropdownOption[]>(() => proxies.map(p => ({ label: p.id + ' ' + p.type + ' ' + p.address, value: p.id })), [proxies]);

  const boolValues = [
    'true',
    'false',
  ]

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
        accessorKey: 'serve',
        header: 'Serve',
        Cell: ({ cell }) => (
          <Checkbox checked={cell.row.original.serve} disabled />
        ),
        maxSize: 80,
        editVariant: 'select',
        editSelectOptions: boolValues,
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.serve,
          helperText: validationErrors?.serve,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              serve: undefined,
            }),
          // optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'servePath',
        header: 'Serve path',
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.servePath,
          helperText: validationErrors?.servePath,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              servePath: undefined,
            }),
          // optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'saveToFS',
        header: 'Save',
        Cell: ({ cell }) => (
          <Checkbox checked={cell.row.original.saveToFS} disabled />
        ),
        maxSize: 80,
        editVariant: 'select',
        editSelectOptions: boolValues,
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.saveToFS,
          helperText: validationErrors?.saveToFS,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              saveToFS: undefined,
            }),
          // optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'saveToFSPath',
        header: 'Save path',
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.saveToFSPath,
          helperText: validationErrors?.saveToFSPath,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              saveToFSPath: undefined,
            }),
          // optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'fallBackProxyId',
        Cell: ({ row }) => (
          <div>
            {row.original.fallBackProxyType + ' ' + row.original.fallBackProxyAddress}
          </div>
        ),
        header: 'Fallback proxy',
        editVariant: 'select',
        editSelectOptions: proxiesSelectData,
        muiEditTextFieldProps: {
          required: true,
        },
      },
    ],
    [validationErrors, proxiesSelectData],
  );

  // CREATE action
  const handleCreatePAC: MRT_TableOptions<RowData>['onCreatingRowSave'] = async ({
    values,
    table,
  }) => {
    console.debug("handleCreatePAC");

    const newValidationErrors = validatePAC(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const createRequest: PACCreateRequest = {
      name: values.name,
      description: values.description,
      serve: values.serve === 'true',
      servePath: values.servePath,
      saveToFS: values.saveToFS === 'true',
      saveToFSPath: values.saveToFSPath,
      fallbackProxyId: values.fallbackProxyId,
      proxyRules: []
    };

    await createPAC(createRequest).unwrap()
      .then((value: PAC) => {
        // TODO: use value to update row
        table.setCreatingRow(null); // exit creating mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('createPAC()', error)
      });
  };

  // UPDATE action
  const handleSavePAC: MRT_TableOptions<RowData>['onEditingRowSave'] = async ({
    values,
    table,
  }) => {
    console.debug("handleSavePAC");

    const newValidationErrors = validatePAC(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const updateRequestBody: PACUpdateRequest = {
      name: values.name,
      description: values.description,
      serve: values.serve === 'true',
      servePath: values.servePath,
      saveToFS: values.saveToFS === 'true',
      saveToFSPath: values.saveToFSPath,
      fallbackProxyId: values.fallbackProxyId,
      proxyRules: []
    };
    const updateRequest = { id: values.id, body: updateRequestBody }

    await updatePAC(updateRequest).unwrap()
      .then((value: PAC) => {
        // TODO: use value to update row
        table.setEditingRow(null); // exit editing mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('updatePAC()', error)
      });
  };

  // DELETE action
  const openDeleteConfirmModal = (row: MRT_Row<RowData>) => {
    if (window.confirm('Are you sure you want to delete this PAC?')) {
      deletePAC(row.original.id).unwrap().catch((error) => {
        window.alert(getErrorMessage(error));
        console.error('deletePAC()', error)
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
    muiToolbarAlertBannerProps: isFetchingPACsError
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
    onCreatingRowSave: handleCreatePAC,
    onEditingRowCancel: () => { setValidationErrors({}); /* setMutationError(undefined); */ },
    onEditingRowSave: handleSavePAC,
    renderCreateRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4" >Create new PAC</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {internalEditComponents}
          <Typography variant="h6" sx={{ mt: 2 }}>Proxy rules</Typography>
          <ProxyRuleSelector
            proxyRuleIdsWithPriority={row.original.proxyRuleIdsWithPriority ? row.original.proxyRuleIdsWithPriority : []}
            onSelectionChange={(proxyRuleIdsWithPriority) => {
              console.debug("onSelectionChange", proxyRuleIdsWithPriority);
              row._valuesCache.proxyRuleIdsWithPriority = proxyRuleIdsWithPriority;
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
        <DialogTitle variant="h4">Edit PAC</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
          {internalEditComponents}
          <Typography variant="h6" sx={{ mt: 2 }}>Proxy rules</Typography>
          <ProxyRuleSelector
            proxyRuleIdsWithPriority={row.original.proxyRuleIdsWithPriority ? row.original.proxyRuleIdsWithPriority : []}
            onSelectionChange={(proxyRuleIdsWithPriority) => {
              console.debug("onSelectionChange", proxyRuleIdsWithPriority);
              row._valuesCache.proxyRuleIdsWithPriority = proxyRuleIdsWithPriority;
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
          table.setCreatingRow(true); // simplest way to open the create row modal with no default values
          // or you can pass in a row object to set default values with the `createRow` helper function
          // table.setCreatingRow(
          //   createRow(table, {
          //     //optionally pass in default values for the new row, useful for nested data or other complex scenarios
          //   }),
          // );
        }}
      >
        Create new PAC
      </Button>
    ),
    state: {
      isLoading: isFetchingPACs || isFetchingProxies,
      isSaving: createPACResult.isLoading || updatePACResult.isLoading || deletePACResult.isLoading,
      showAlertBanner: isFetchingPACsError,
      showProgressBars: isFetchingPACs || isFetchingProxies,
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

function validatePAC(c: RowData) {
  return {
    name: !validateRequired(c.name) ? 'Name is Required' : '',
  };
}

export default PACs;
