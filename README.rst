Postgres with `Elasticsearch Foreign Data Wrapper`_.

This is based on the offical Dockerfiles from Postgres_ and Elasticsearch_.

.. _Elasticsearch Foreign Data Wrapper: https://github.com/rtkwlf/esfdw
.. _Elasticsearch: https://hub.docker.com/_/elasticsearch/
.. _Postgres: https://hub.docker.com/_/postgres/

Usage
=====
Read the Makefile top to bottom.

Also note ``docker-entrypoint-initdb.d/`` which contains initialization
scripts for Postgres.

Run

::

    make

Load some example data into elasticsearch at ``/bank/account``::

    make load_es_example_data
    make show_es_indices

Select things::

    make selects


.. vim: set ft=rst :
