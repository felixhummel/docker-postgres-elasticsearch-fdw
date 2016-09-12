curl -XGET http://localhost:9200/us_large_cities/city/_search?pretty -d '
{
  "size": 2,
  "fields": ["state", "location.lat"],
  "query": {
    "match_all": {}
  }
}
'

