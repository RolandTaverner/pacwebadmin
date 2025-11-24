// import { useState } from 'react'

import type { FetchBaseQueryError } from '@reduxjs/toolkit/query';
import type { SerializedError } from '@reduxjs/toolkit';

import type { ErrorResponse } from "../../services/types";

export function MutationError(error: FetchBaseQueryError | SerializedError | undefined) {
    if (error == null) {
        return (<></>);
    }

    console.debug('MutationError error: ', error);

    return <div>{getErrorMessage(error)}</div>;
}

export function getErrorMessage(error: FetchBaseQueryError | SerializedError | undefined) {
    if (error == null) {
        return '';
    }

    if ('data' in error && 'status' in error) {
        const { status, data } = error;
        if (data != null && 'statusMessage' in data) {
            const er = data as ErrorResponse;
            return er.statusMessage;
        }

        return 'server returned HTTP status ' + status;
    } else if (error instanceof Error) {
        return error.message;
    }

    return 'Unknown Error: ' + error
}
