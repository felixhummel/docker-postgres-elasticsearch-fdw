# http://www.elasticsearchtutorial.com/spatial-search-tutorial.html
curl -XPUT http://localhost:9200/us_large_cities -d '
{
    "mappings": {
        "city": {
            "properties": {
                "city": {"type": "string"},
                "state": {"type": "string"},
                "location": {"type": "geo_point", "lat_lon": true}
            }
        }
    }
}
'
