CREATE SERVER es FOREIGN DATA WRAPPER multicorn OPTIONS (
    wrapper 'esfdw.ESForeignDataWrapper',
    hostname 'elasticsearch',
    port '9200'
);
