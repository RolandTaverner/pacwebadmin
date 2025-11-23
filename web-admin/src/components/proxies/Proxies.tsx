import { useMemo, useState } from 'react'
import './Proxies.css'

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
} from 'material-react-table';

import { useAllProxiesQuery, useCreateProxyMutation, useUpdateProxyMutation, useDeleteProxyMutation } from '../../services/proxy';
import type { Proxy, ProxyCreateRequest, ProxyUpdateRequest } from "../../services/types";
import { MutationError, getErrorMessage } from '../errors/errors';

function Proxies() {
  const { data: proxies = [], isLoading, isFetching: isFetchingProxies, isError: isFetchingProxiesError } = useAllProxiesQuery();
  const [validationErrors, setValidationErrors] = useState<Record<string, string | undefined>>({});
  const [mutationError, setMutationError] = useState<FetchBaseQueryError | SerializedError | undefined>(undefined);

  // call CREATE hook
  const [createProxy, createProxyResult] = useCreateProxyMutation()
  // call UPDATE hook
  const [updateProxy, updateProxyResult] = useUpdateProxyMutation()
  // call DELETE hook
  const [deleteProxy, deleteProxyResult] = useDeleteProxyMutation()

  const columns = useMemo<MRT_ColumnDef<Proxy>[]>(
    () => [
      {
        accessorKey: 'id',
        header: 'Id',
        enableEditing: false,
        size: 80,
      },
      {
        accessorKey: 'type',
        header: 'Type',
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.type,
          helperText: validationErrors?.type,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              type: undefined,
            }),
          //optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'address',
        header: 'Address',
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.address,
          helperText: validationErrors?.address,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              address: undefined,
            }),
          //optionally add validation checking for onBlur or onChange
        },
      },
    ],
    [ /*validationErrors */],
  );

  // CREATE action
  const handleCreateProxy: MRT_TableOptions<Proxy>['onCreatingRowSave'] = async ({
    values,
    table,
  }) => {
    const newValidationErrors = validateProxy(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const createRequest: ProxyCreateRequest = { type: values.type, address: values.address, description: '' };

    await createProxy(createRequest).unwrap()
      .then((value: Proxy) => {
        // TODO: use value to update row
        table.setCreatingRow(null); // exit creating mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('createProxy()', error)
      });
  };

  // UPDATE action
  const handleSaveProxy: MRT_TableOptions<Proxy>['onEditingRowSave'] = async ({
    values,
    table,
  }) => {
    const newValidationErrors = validateProxy(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const updateRequestBody: ProxyUpdateRequest = { type: values.type, address: values.address }
    const updateRequest = { id: values.id, body: updateRequestBody }

    await updateProxy(updateRequest).unwrap()
      .then((value: Proxy) => {
        // TODO: use value to update row
        table.setCreatingRow(null); // exit creating mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('updateProxy()', error)
      });
  };

  // DELETE action
  const openDeleteConfirmModal = (row: MRT_Row<Proxy>) => {
    if (window.confirm('Are you sure you want to delete this proxy?')) {
      deleteProxy(row.original.id).unwrap().catch((error) => {
        window.alert(getErrorMessage(error));
        console.error('deleteProxy()', error)
      });
    }
  };

  const table = useMaterialReactTable({
    columns,
    data: proxies,
    createDisplayMode: 'modal', // default ('row', and 'custom' are also available)
    editDisplayMode: 'modal', // default ('row', 'cell', 'table', and 'custom' are also available)
    enableEditing: true,
    getRowId: (row, index, parent) => { let id = row?.id ? row.id.toString() : 'idx' + index.toString(); return id; },
    muiToolbarAlertBannerProps: isFetchingProxiesError
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
    onCreatingRowCancel: () => { setValidationErrors({}); setMutationError(undefined); },
    onCreatingRowSave: handleCreateProxy,
    onEditingRowCancel: () => { setValidationErrors({}); setMutationError(undefined); },
    onEditingRowSave: handleSaveProxy,
    // optionally customize modal content
    renderCreateRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4">Create new Proxy</DialogTitle>
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
        <DialogTitle variant="h4">Edit Proxy</DialogTitle>
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
        Create new Proxy
      </Button>
    ),
    state: {
      isLoading: isFetchingProxies,
      isSaving: createProxyResult.isLoading || updateProxyResult.isLoading || deleteProxyResult.isLoading,
      showAlertBanner: isFetchingProxiesError,
      showProgressBars: isFetchingProxies,
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

const validateRequired = (value: string) => !!value.length;

function validateProxy(c: Proxy) {
  return {
    type: !validateRequired(c.type) ? 'Type is Required' : '',
    address: !validateRequired(c.address) ? 'Address is Required' : '',
  };
}

export default Proxies;
