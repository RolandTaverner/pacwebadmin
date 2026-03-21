import React, { useState } from 'react';

import {
  Alert,
  Button,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControl,
  FormHelperText,
  InputLabel,
  MenuItem,
  TextField,
  Typography,
} from '@mui/material';
import Select from '@mui/material/Select';
import type { SelectChangeEvent } from '@mui/material/Select';

import { useAllCategoriesQuery } from '../../services/category';
import { useAllProxyRulesQuery } from '../../services/proxyrule';
import { useQuickAddConditionsMutation } from '../../services/tool';
import type { ConditionType, ToolQuickAddConditionError } from '../../services/types';
import { getErrorMessage } from '../errors/errors';

const conditionTypeOptions: { label: string; value: ConditionType }[] = [
  { label: 'Domain', value: 'host_domain_only' },
  { label: 'Domain or subdomain', value: 'host_domain_subdomain' },
  { label: 'Subdomain only', value: 'host_subdomain_only' },
  { label: 'URL shell expression', value: 'url_shexp_match' },
  { label: 'URL regular expression', value: 'url_regexp_match' },
];

interface FormState {
  conditionType: ConditionType | '';
  categoryId: number | '';
  proxyRuleId: number | '';
  expressionsText: string;
}

interface FormErrors {
  conditionType?: string;
  categoryId?: string;
  proxyRuleId?: string;
  expressionsText?: string;
}

const emptyForm: FormState = {
  conditionType: '',
  categoryId: '',
  proxyRuleId: '',
  expressionsText: '',
};

const QuickAddConditionsDialog: React.FC<{
  open: boolean;
  onClose: () => void;
}> = ({ open, onClose }) => {
  const { data: categories = [], isFetching: isFetchingCategories } = useAllCategoriesQuery();
  const { data: proxyRules = [], isFetching: isFetchingProxyRules } = useAllProxyRulesQuery();
  const [quickAddConditions, { isLoading }] = useQuickAddConditionsMutation();

  const [form, setForm] = useState<FormState>(emptyForm);
  const [formErrors, setFormErrors] = useState<FormErrors>({});
  const [mutationError, setMutationError] = useState<string | undefined>(undefined);
  const [responseErrors, setResponseErrors] = useState<ToolQuickAddConditionError[]>([]);

  const resetState = () => {
    setForm(emptyForm);
    setFormErrors({});
    setMutationError(undefined);
    setResponseErrors([]);
  };

  const handleClose = () => {
    resetState();
    onClose();
  };

  const validate = (): FormErrors => {
    const errors: FormErrors = {};
    if (!form.conditionType) errors.conditionType = 'Required';
    if (form.categoryId === '') errors.categoryId = 'Required';
    if (form.proxyRuleId === '') errors.proxyRuleId = 'Required';
    if (!form.expressionsText.trim()) errors.expressionsText = 'At least one expression is required';
    return errors;
  };

  const handleSubmit = async () => {
    const errors = validate();
    if (Object.values(errors).some(Boolean)) {
      setFormErrors(errors);
      return;
    }
    setFormErrors({});
    setMutationError(undefined);
    setResponseErrors([]);

    const expressions = form.expressionsText
      .split('\n')
      .map(e => e.trim())
      .filter(e => e.length > 0);

    try {
      const result = await quickAddConditions({
        type: form.conditionType as ConditionType,
        categoryId: form.categoryId as number,
        proxyRuleId: form.proxyRuleId as number,
        expressions,
      }).unwrap();

      if (result.errors.length > 0) {
        setResponseErrors(result.errors);
      } else {
        handleClose();
      }
    } catch (error: unknown) {
      setMutationError(getErrorMessage(error as Parameters<typeof getErrorMessage>[0]));
    }
  };

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle>Quick Add Conditions</DialogTitle>
      <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '1rem', pt: '1rem !important' }}>

        <FormControl fullWidth error={!!formErrors.conditionType}>
          <InputLabel>Condition type</InputLabel>
          <Select
            value={form.conditionType}
            label="Condition type"
            onChange={(e: SelectChangeEvent) => {
              setForm({ ...form, conditionType: e.target.value as ConditionType });
              setFormErrors({ ...formErrors, conditionType: undefined });
            }}
          >
            {conditionTypeOptions.map(opt => (
              <MenuItem key={opt.value} value={opt.value}>{opt.label}</MenuItem>
            ))}
          </Select>
          {formErrors.conditionType && <FormHelperText>{formErrors.conditionType}</FormHelperText>}
        </FormControl>

        <FormControl fullWidth error={!!formErrors.categoryId}>
          <InputLabel>Category</InputLabel>
          <Select<number | ''>
            value={form.categoryId}
            label="Category"
            disabled={isFetchingCategories}
            onChange={(e: SelectChangeEvent<number | ''>) => {
              setForm({ ...form, categoryId: e.target.value as number });
              setFormErrors({ ...formErrors, categoryId: undefined });
            }}
          >
            {categories.map(c => (
              <MenuItem key={c.id} value={c.id}>{c.name}</MenuItem>
            ))}
          </Select>
          {formErrors.categoryId && <FormHelperText>{formErrors.categoryId}</FormHelperText>}
        </FormControl>

        <FormControl fullWidth error={!!formErrors.proxyRuleId}>
          <InputLabel>Proxy rule</InputLabel>
          <Select<number | ''>
            value={form.proxyRuleId}
            label="Proxy rule"
            disabled={isFetchingProxyRules}
            onChange={(e: SelectChangeEvent<number | ''>) => {
              setForm({ ...form, proxyRuleId: e.target.value as number });
              setFormErrors({ ...formErrors, proxyRuleId: undefined });
            }}
          >
            {proxyRules.map(r => (
              <MenuItem key={r.id} value={r.id}>{r.name}</MenuItem>
            ))}
          </Select>
          {formErrors.proxyRuleId && <FormHelperText>{formErrors.proxyRuleId}</FormHelperText>}
        </FormControl>

        <TextField
          label="Expressions (one per line)"
          multiline
          minRows={4}
          fullWidth
          value={form.expressionsText}
          error={!!formErrors.expressionsText}
          helperText={formErrors.expressionsText}
          onChange={(e) => {
            setForm({ ...form, expressionsText: e.target.value });
            setFormErrors({ ...formErrors, expressionsText: undefined });
          }}
        />

        {mutationError && (
          <Alert severity="error">{mutationError}</Alert>
        )}

        {responseErrors.length > 0 && (
          <Alert severity="warning">
            <Typography variant="body2" fontWeight="bold">Some expressions failed:</Typography>
            {responseErrors.map((e, i) => (
              <Typography key={i} variant="body2">{e.expression}: {e.error}</Typography>
            ))}
          </Alert>
        )}

      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>Cancel</Button>
        <Button
          onClick={handleSubmit}
          variant="contained"
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={16} /> : undefined}
        >
          Add
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default QuickAddConditionsDialog;
