import React, { useState } from 'react';

import {
  Checkbox,
  FormControlLabel,
  Typography
} from '@mui/material';

interface CheckboxEditProps {
  label: string,
  required: boolean,
  checkedInitial: boolean;
  onChange: (checked: boolean) => void;
}

const CheckboxEdit: React.FC<CheckboxEditProps> = ({
  label,
  required,
  checkedInitial,
  onChange,
}) => {
  console.debug("=================== CheckboxEdit");
  const [isChecked, setIsChecked] = useState(checkedInitial);

  const onChangeHandler = (event: React.ChangeEvent<HTMLInputElement>, checked: boolean) => {
    console.log(checked);
    setIsChecked(checked);
    onChange(checked);
  };

  return (
    <>
      <FormControlLabel
        required={required}
        //label={label}
        label={<Typography height='11px' lineHeight='11px' fontSize='1em' sx={{ display: 'inline' }}>{label}</Typography>}
        labelPlacement='top'
        control={<Checkbox checked={isChecked} onChange={onChangeHandler} sx={{ paddingLeft: 0, paddingBottom: 0 }} />}
        sx={{ fontSize: '1em', paddingTop: 0, alignItems: "start", marginLeft: 0 }}
      />
      {/* <Divider></Divider> */}
    </>
  );
};

export default CheckboxEdit;