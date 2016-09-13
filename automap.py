"""
Create foreign tables for all indices and doc types present in an
Elastic Search cluster.
"""
from elasticsearch import Elasticsearch
from esfdw.mapping_to_schema import generate_schema

es = Elasticsearch(hosts=['elasticsearch:9200'])
mapping = es.indices.get_mapping()


def get_sql(mapping, index, doctype, table_prefix=''):
    table_name = '_'.join((table_prefix, index, doctype))
    lines = generate_schema(mapping, index, doctype, table_name)
    sql = '\n'.join(lines)
    return sql


def iter_index_doctype_pairs():
    for index in mapping:
        for doctype in mapping[index]['mappings']:
            yield index, doctype


for index, doctype in iter_index_doctype_pairs():
    print '-- {0}/{1}'.format(index, doctype)
    print get_sql(mapping, index, doctype, 'elasticsearch_9200')

