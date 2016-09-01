Postgres with `Elasticsearch Foreign Data Wrapper`_.

This is based on the offical Dockerfiles from Postgres_ and Elasticsearch_.

.. _Elasticsearch Foreign Data Wrapper: https://github.com/rtkwlf/esfdw
.. _Elasticsearch: https://hub.docker.com/_/elasticsearch/
.. _Postgres: https://github.com/docker-library/postgres/blob/master/9.5/Dockerfile

Usage
=====
Read the Makefile top to bottom.

Run

::

    make

Load some example data into elasticsearch at ``/bank/account``::

    make load_es_example_data
    make show_es_indices

Then run the following in another terminal::

    make 1_create_extension
    make 2_create_server_es
    make 3_create_foreign_table
    make 4_selects

And check the contents of ``usage/*.sql``.
    

.. vim: set ft=rst :
