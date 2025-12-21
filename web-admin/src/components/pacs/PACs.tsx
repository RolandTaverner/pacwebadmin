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

import type { Row, FilterFn, FilterMeta } from '@tanstack/react-table';
import { filterFns, getFilteredRowModel } from '@tanstack/react-table';

import {
  MRT_EditActionButtons,
  MaterialReactTable,
  type MRT_ColumnDef,
  type MRT_Row,
  type MRT_TableOptions,
  useMaterialReactTable,
  type DropdownOption,
} from 'material-react-table';

import { useAllPACsQuery, useCreatePACMutation, useUpdatePACMutation, useDeletePACMutation, usePacProxyRulesQuery } from '../../services/pac';
import { useAllProxiesQuery } from '../../services/proxy';
import type { PAC, PACShort, PACCreateRequest, PACUpdateRequest, ProxyRuleIdWithPriority, Proxy } from "../../services/types";
import { MutationError, getErrorMessage } from '../errors/errors';
import ProxyRuleSelector from './ProxyRuleSelector';
import CheckboxEdit from '../common/CheckboxEdit';
import ProxyCell, { displayProxyString } from '../common/ProxyCell';

class RowData {
  id: number;
  name: string;
  description: string;
  serve: boolean;
  servePath: string;
  saveToFS: boolean;
  saveToFSPath: string;
  fallbackProxy?: Proxy;
  fallbackProxyId?: number;
  fallbackProxyDisplayString?: string;
  proxyRuleIdsWithPriority?: ProxyRuleIdWithPriority[];

  constructor(
    id: number,
    name: string,
    description: string,
    serve: boolean,
    servePath: string,
    saveToFS: boolean,
    saveToFSPath: string,
    fallbackProxy?: Proxy,
  ) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.serve = serve;
    this.servePath = servePath;
    this.saveToFS = saveToFS;
    this.saveToFSPath = saveToFSPath;
    this.fallbackProxy = fallbackProxy;
    this.fallbackProxyId = fallbackProxy?.id;
    this.fallbackProxyDisplayString = displayProxyString(fallbackProxy);
    this.proxyRuleIdsWithPriority = undefined;
  }
}

function RowDataFromPAC(p: PACShort): RowData {
  return new RowData(p.id,
    p.name,
    p.description,
    p.serve, p.servePath,
    p.saveToFS, p.saveToFSPath,
    p.fallbackProxy,
  );
}

function fallbackProxyFilterFn(row: Row<RowData>, columnId: string, filterValue: any, addMeta: (meta: FilterMeta) => void): boolean {
  if (row.original.fallbackProxyDisplayString == null) {
    return false;
  }

  return row.original.fallbackProxyDisplayString.toLowerCase().includes(filterValue.toLowerCase());
}

const customGlobalFilter: FilterFn<RowData> = (row: Row<RowData>, columnId: string, filterValue: string, addMeta: (meta: FilterMeta) => void) => {
  const customFilterFn = row
    .getVisibleCells()
    .find((c) => c.column.id === columnId)
    ?.column.getFilterFn();

  if (typeof customFilterFn === "function") {
    return customFilterFn(row as Row<RowData>, columnId, filterValue, addMeta);
  }

  return filterFns.includesString(row as Row<RowData>, columnId, filterValue, addMeta);
};

interface ProxyRuleSelectorWrapperProps {
  row: MRT_Row<RowData>;
  component: 'create' | 'edit';
}

const ProxyRuleSelectorWrapper: React.FC<ProxyRuleSelectorWrapperProps> = ({ row, component }) => {
  const pacId = row.original.id;
  const { data: proxyRulesData } = usePacProxyRulesQuery(pacId, { skip: component === 'create' });

  // Prefer cached values from row if they exist (user has made changes)
  // Otherwise use fetched data from the query
  const proxyRuleIdsWithPriority: ProxyRuleIdWithPriority[] =
    row._valuesCache.proxyRuleIdsWithPriority ||
    proxyRulesData?.map<ProxyRuleIdWithPriority>(i => ({
      proxyRuleId: i.proxyRule.id,
      priority: i.priority
    })) || [];

  console.debug(component, 'ProxyRuleSelectorWrapper proxyRuleIdsWithPriority', proxyRuleIdsWithPriority);

  return (
    <ProxyRuleSelector
      proxyRuleIdsWithPriority={proxyRuleIdsWithPriority}
      onSelectionChange={(proxyRuleIdsWithPriority) => {
        console.debug("ProxyRuleSelectorWrapper.onSelectionChange", proxyRuleIdsWithPriority);
        row._valuesCache.proxyRuleIdsWithPriority = proxyRuleIdsWithPriority;
      }}
    />
  );
};

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
        maxSize: 100,
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
        size: 80,
        Cell: ({ cell }) => (
          <Checkbox checked={cell.row.original.serve} disabled name='serve' />
        ),
        Edit: ({ cell, column, row, table }) => {
          const onChange = (checked: boolean) => {
            row._valuesCache[column.id] = checked;
          };
          const checkedInitial: boolean = cell.row.original.serve ? cell.row.original.serve : false;
          return <CheckboxEdit required={true} label='Serve' checkedInitial={checkedInitial} onChange={onChange} />
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
        size: 80,
        Cell: ({ cell }) => (
          <Checkbox checked={cell.row.original.saveToFS} disabled name='saveToFS' />
        ),
        Edit: ({ cell, column, row, table }) => {
          const onChange = (checked: boolean) => {
            row._valuesCache[column.id] = checked;
          };
          const checkedInitial: boolean = cell.row.original.saveToFS ? cell.row.original.saveToFS : false;
          return <CheckboxEdit required={true} label='Save' checkedInitial={checkedInitial} onChange={onChange} />
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
        accessorKey: 'fallbackProxyId',
        Cell: ({ row }) => (
          <ProxyCell proxy={row.original.fallbackProxy} maxWidth={500} />
        ),
        header: 'Fallback proxy',
        editVariant: 'select',
        editSelectOptions: proxiesSelectData,
        muiEditTextFieldProps: {
          required: true,
        },
        filterFn: fallbackProxyFilterFn,
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
      description: values.description ? values.description : '',
      serve: (typeof values.serve === 'boolean') ? values.serve : false,
      servePath: values.servePath != null ? values.servePath : '',
      saveToFS: (typeof values.saveToFS === 'boolean') ? values.saveToFS : false,
      saveToFSPath: values.saveToFSPath != null ? values.saveToFSPath : '',
      fallbackProxyId: values.fallbackProxyId,
      proxyRules: values.proxyRuleIdsWithPriority ? values.proxyRuleIdsWithPriority : [],
    };

    console.debug("handleCreatePAC: createRequest", createRequest);

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
      serve: values.serve,
      servePath: values.servePath,
      saveToFS: values.saveToFS,
      saveToFSPath: values.saveToFSPath,
      fallbackProxyId: values.fallbackProxyId,
      proxyRules: values.proxyRuleIdsWithPriority,
    };
    const updateRequest = { id: values.id, body: updateRequestBody }

    console.debug("handleSavePAC: updateRequest", updateRequest);

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
          <ProxyRuleSelectorWrapper
            row={row}
            component='create'
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
          <ProxyRuleSelectorWrapper
            row={row}
            component='edit'
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
        Create new PAC
      </Button>
    ),
    filterFns: {
      customGlobalFilter: customGlobalFilter,
    },
    globalFilterFn: 'customGlobalFilter',
    getFilteredRowModel: getFilteredRowModel(),
    manualFiltering: false,
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
