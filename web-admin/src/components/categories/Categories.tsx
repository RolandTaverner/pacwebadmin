import { useMemo, useState } from 'react'
import './Categories.css'

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

import { useAllCategoriesQuery, useCreateCategoryMutation, useUpdateCategoryMutation, useDeleteCategoryMutation } from '../../services/category';
import type { Category, CategoryCreateRequest, CategoryUpdateRequest } from "../../services/types";
import { MutationError, getErrorMessage } from '../errors/errors';

function Categories() {
  console.debug("=================== Categories");

  const { data: categories = [], isLoading, isFetching: isFetchingCategories, isError: isFetchingCategoriesError } = useAllCategoriesQuery();
  const [validationErrors, setValidationErrors] = useState<Record<string, string | undefined>>({});
  const [mutationError, setMutationError] = useState<FetchBaseQueryError | SerializedError | undefined>(undefined);

  // call CREATE hook
  const [createCategory, createCategoryResult] = useCreateCategoryMutation()
  // call UPDATE hook
  const [updateCategory, updateCategoryResult] = useUpdateCategoryMutation()
  // call DELETE hook
  const [deleteCategory, deleteCategoryResult] = useDeleteCategoryMutation()

  const columns = useMemo<MRT_ColumnDef<Category>[]>(
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
          //optionally add validation checking for onBlur or onChange
        },
      },
    ],
    [ validationErrors ],
  );

  // CREATE action
  const handleCreateCategory: MRT_TableOptions<Category>['onCreatingRowSave'] = async ({
    values,
    table,
  }) => {
    const newValidationErrors = validateCategory(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const createRequest: CategoryCreateRequest = { name: values.name };

    await createCategory(createRequest).unwrap()
      .then((value: Category) => {
        // TODO: use value to update row
        table.setCreatingRow(null); // exit creating mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('createCategory()', error)
      });
  };

  // UPDATE action
  const handleSaveCategory: MRT_TableOptions<Category>['onEditingRowSave'] = async ({
    values,
    table,
  }) => {
    const newValidationErrors = validateCategory(values);
    if (Object.values(newValidationErrors).some((error) => error)) {
      setValidationErrors(newValidationErrors);
      return;
    }
    setValidationErrors({});

    const updateRequestBody: CategoryUpdateRequest = { name: values.name }
    const updateRequest = { id: values.id, body: updateRequestBody }

    await updateCategory(updateRequest).unwrap()
      .then((value: Category) => {
        // TODO: use value to update row
        table.setEditingRow(null); // exit editing mode
        setMutationError(undefined);
      })
      .catch((error) => {
        setMutationError(error);
        console.error('updateCategory()', error)
      });
  };

  // DELETE action
  const openDeleteConfirmModal = (row: MRT_Row<Category>) => {
    if (window.confirm('Are you sure you want to delete this category?')) {
      deleteCategory(row.original.id).unwrap().catch((error) => {
        window.alert(getErrorMessage(error));
        console.error('deleteCategory()', error)
      });
    }
  };

  const table = useMaterialReactTable({
    columns,
    data: categories,
    createDisplayMode: 'modal', // default ('row', and 'custom' are also available)
    editDisplayMode: 'modal', // default ('row', 'cell', 'table', and 'custom' are also available)
    enableEditing: true,
    getRowId: (row, index, parent) => { let id = row?.id ? row.id.toString() : 'idx' + index.toString(); return id; },
    muiToolbarAlertBannerProps: isFetchingCategoriesError
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
    onCreatingRowSave: handleCreateCategory,
    onEditingRowCancel: () => { setValidationErrors({}); setMutationError(undefined); },
    onEditingRowSave: handleSaveCategory,
    // optionally customize modal content
    renderCreateRowDialogContent: ({ table, row, internalEditComponents }) => (
      <>
        <DialogTitle variant="h4">Create new Category</DialogTitle>
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
        <DialogTitle variant="h4">Edit Category</DialogTitle>
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
        Create new Category
      </Button>
    ),
    state: {
      isLoading: isFetchingCategories,
      isSaving: createCategoryResult.isLoading || updateCategoryResult.isLoading || deleteCategoryResult.isLoading,
      showAlertBanner: isFetchingCategoriesError,
      showProgressBars: isFetchingCategories,
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

function validateCategory(c: Category) {
  return {
    name: !validateRequired(c.name) ? 'Name is Required' : ''
  };
}

export default Categories;
