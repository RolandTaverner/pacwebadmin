import { useMemo, useState } from 'react';
import './Conditions.css';

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

import { useAllConditionsQuery, useCreateConditionMutation, useUpdateConditionMutation, useDeleteConditionMutation } from '../../services/condition';
import { useAllCategoriesQuery } from '../../services/category';
import type { Condition, ConditionCreateRequest, ConditionUpdateRequest, Category } from "../../services/types";
import { MutationError, getErrorMessage } from '../errors/errors';

class RowData {
  id: number;
  type: string;
  expression?: string;
  category?: Category;
  categoryId?: number;
  categoryName?: string;

  constructor(id: number, type: string, expression?: string, category?: Category) {
    this.id = id;
    this.type = type;
    this.expression = expression;
    this.category = category;
    this.categoryId = category?.id;
    this.categoryName = category?.name;
  }
}

function RowDataFromCondition(p: Condition): RowData {
  return new RowData(p.id, p.type, p.expression, p.category);
}

function categoryFilterFn(row: Row<RowData>, columnId: string, filterValue: any, addMeta: (meta: FilterMeta) => void): boolean {
  if (row.original.categoryName == null) {
    return false;
  }

  return row.original.categoryName.toLowerCase().includes(filterValue.toLowerCase());
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

const conditionTypes = [
  'host_domain_only',
  'host_domain_subdomain',
  'host_subdomain_only',
  'url_shexp_match',
  'url_regexp_match'
];

const conditionTypeSelectData: DropdownOption[] = [
  { label: 'Domain', value: 'host_domain_only' },
  { label: 'Domain or subdomain', value: 'host_domain_subdomain' },
  { label: 'Subdomain only', value: 'host_subdomain_only' },
  { label: 'URL shell expression', value: 'url_shexp_match' },
  { label: 'URL regular expression', value: 'url_regexp_match' },
];

function Conditions() {
  console.debug("=================== Conditions");

  const { data: conditions = [], isFetching: isFetchingConditions, isError: isFetchingConditionsError } = useAllConditionsQuery();
  const { data: categories = [], isFetching: isFetchingCategories, isError: isFetchingCategoriesError } = useAllCategoriesQuery();

  const [validationErrors, setValidationErrors] = useState<Record<string, string | undefined>>({});
  const [mutationError, setMutationError] = useState<FetchBaseQueryError | SerializedError | undefined>(undefined);

  // call CREATE hook
  const [createCondition, createConditionResult] = useCreateConditionMutation()
  // call UPDATE hook
  const [updateCondition, updateConditionResult] = useUpdateConditionMutation()
  // call DELETE hook
  const [deleteCondition, deleteConditionResult] = useDeleteConditionMutation()

  const rowsData = useMemo<RowData[]>(() => conditions.map(p => RowDataFromCondition(p)), [conditions]);
  const categoriesSelectData = useMemo<DropdownOption[]>(() => categories.map(c => ({ label: c.name, value: c.id })), [categories]);

  const columns = useMemo<MRT_ColumnDef<RowData>[]>(
    () => [
      {
        accessorKey: 'id',
        header: 'Id',
        enableEditing: false,
        size: 50,
      },
      {
        accessorKey: 'type',
        header: 'Type',
        editVariant: 'select',
        editSelectOptions: conditionTypeSelectData,
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
        accessorKey: 'expression',
        header: 'Expression',
        muiEditTextFieldProps: {
          required: false,
          error: !!validationErrors?.expression,
          helperText: validationErrors?.expression,
          // remove any previous validation errors when user focuses on the input
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              expression: undefined,
            }),
          // optionally add validation checking for onBlur or onChange
        },
      },
      {
        accessorKey: 'categoryId',
        Cell: ({ row }) => (
          <div>
            {row.original.categoryName}
          </div>
        ),
        header: 'Category',
        editVariant: 'select',
        editSelectOptions: categoriesSelectData,
        muiEditTextFieldProps: {
          required: true,
        },
        filterFn: categoryFilterFn,
      },
    ],
    [validationErrors, categoriesSelectData],
  );

  // CREATE action
  const handleCreateCondition: MRT_TableOptions<RowData>['onCreatingRowSave'] = async ({
    values,
    table,
  }) => {
    console.debug("handleCreateCondition");

    const newValidationErrors = validateCondition(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const createRequest: ConditionCreateRequest = { type: values.type, expression: values.expression, categoryId: values.categoryId };

    await createCondition(createRequest).unwrap()
      .then((value: Condition) => {
        // TODO: use value to update row
        table.setCreatingRow(null); // exit creating mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('createCondition()', error)
      });
  };

  // UPDATE action
  const handleSaveCondition: MRT_TableOptions<RowData>['onEditingRowSave'] = async ({
    values,
    table,
  }) => {
    console.debug("handleSaveCondition");

    const newValidationErrors = validateCondition(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    let updateRequestBody: ConditionUpdateRequest = { type: values.type, expression: values.expression, categoryId: values.categoryId }
    const updateRequest = { id: values.id, body: updateRequestBody }

    await updateCondition(updateRequest).unwrap()
      .then((value: Condition) => {
        // TODO: use value to update row
        table.setEditingRow(null); // exit editing mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('updateCondition()', error)
      });
  };

  // DELETE action
  const openDeleteConfirmModal = (row: MRT_Row<RowData>) => {
    if (window.confirm('Are you sure you want to delete this condition?')) {
      deleteCondition(row.original.id).unwrap().catch((error) => {
        window.alert(getErrorMessage(error));
        console.error('deleteCondition()', error)
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
    muiToolbarAlertBannerProps: isFetchingConditionsError
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
    onCreatingRowSave: handleCreateCondition,
    onEditingRowCancel: () => { setValidationErrors({}); /* setMutationError(undefined); */ },
    onEditingRowSave: handleSaveCondition,
    renderCreateRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4">Create new Condition</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {internalEditComponents}
          {MutationError(mutationError)}
        </DialogContent>
        <DialogActions>
          <MRT_EditActionButtons variant="text" table={table} row={row} />
        </DialogActions>
      </>
    ),
    renderEditRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4">Edit Condition</DialogTitle>
        <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
          {internalEditComponents}
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
        Create new Condition
      </Button>
    ),
    filterFns: {
      customGlobalFilter: customGlobalFilter,
    },
    globalFilterFn: 'customGlobalFilter',
    getFilteredRowModel: getFilteredRowModel(),
    manualFiltering: false,
    state: {
      isLoading: isFetchingConditions || isFetchingCategories,
      isSaving: createConditionResult.isLoading || updateConditionResult.isLoading || deleteConditionResult.isLoading,
      showAlertBanner: isFetchingConditionsError,
      showProgressBars: isFetchingConditions || isFetchingCategories,
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

function validateCondition(c: RowData) {
  return {
    type: !validateRequired(c.type) ? 'Type is Required' : '',
    expression: !validateRequired(c.expression) ? 'Expression is Required' : '',
  };
}

export default Conditions;
