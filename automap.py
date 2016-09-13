"""
Create foreign tables for all indices and doc types present in an
Elastic Search cluster.
"""
from elasticsearch import Elasticsearch
from esfdw.mapping_to_schema import generate_table_spec

ES_SERVER_ALIAS = 'elasticsearch_9200'

es = Elasticsearch(hosts=['elasticsearch:9200'])
mapping = es.indices.get_mapping()


def generate_schema(mapping, include_indices, include_doc_types, server, table_name):
    """
    Column names with double quotes by default, to get around issues
    with reserved keywords.

    Custom table names.

    See esfdw.mapping_to_schema for more.
    """
    for table_spec in generate_table_spec(
            mapping, include_indices, include_doc_types):
        columns = ',\n'.join(
            '    "%s" %s' %
            (col.column_name, col.data_type) for col in table_spec.columns)
        yield \
            """DROP FOREIGN TABLE IF EXISTS %(table)s;
CREATE FOREIGN TABLE %(table)s (
%(columns)s
) SERVER %(server)s OPTIONS (
    doc_type '%(doc_type)s',
    index '%(index)s',
    column_name_translation 'true'
);
""" % {'table': table_name, 'columns': columns, 'server': server,
'doc_type': table_spec.doc_type, 'index': table_spec.index}


def get_sql(mapping, index, doctype, server, table_prefix=''):
    table_name = '_'.join((table_prefix, index, doctype))
    lines = generate_schema(mapping, index, doctype, server, table_name)
    sql = '\n'.join(lines)
    return sql


def iter_index_doctype_pairs():
    for index in mapping:
        for doctype in mapping[index]['mappings']:
            yield index, doctype


for index, doctype in iter_index_doctype_pairs():
    print '-- {0}/{1}'.format(index, doctype)
    print get_sql(mapping, index, doctype, 'es', 'elasticsearch_9200')

