DROP FOREIGN TABLE IF EXISTS account;
CREATE FOREIGN TABLE account (
    city text,
    firstname text,
    gender text,
    age bigint,
    employer text,
    state text,
    account_number bigint,
    lastname text,
    address text,
    balance bigint,
    email text
) SERVER es OPTIONS (
    doc_type 'account',
    index 'bank'
);

