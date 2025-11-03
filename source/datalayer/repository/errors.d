module datalayer.repository.errors;

import std.exception;

class RepositoryError : Exception
{
    mixin basicExceptionCtors;
}

class NotFoundError : RepositoryError
{
    mixin basicExceptionCtors;
}

class AlreadyExistsError : RepositoryError
{
    mixin basicExceptionCtors;
}
