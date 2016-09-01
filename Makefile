image_name := pg_es_fdw
# docker compose convention
container_postgres := postgresesfdw_postgres_1
container_elasticsearch := postgresesfdw_elasticsearch_1
# if the containers run, those contain their IP addresses
ip_postgres := $(shell docker inspect --format '{{ .NetworkSettings.Networks.postgresesfdw_default.IPAddress }}' $(container_postgres))
ip_elasticsearch := $(shell docker inspect --format '{{ .NetworkSettings.Networks.postgresesfdw_default.IPAddress }}' $(container_elasticsearch))

default: build

# used in ADD clause in Dockerfile
esfdw:
	git submodule update --init

build: esfdw
	docker build -t $(image_name) .

run:
	docker run --rm -e POSTGRES_PASSWORD=geheim --name $(container_postgres) $(image_name) 

# if started via run, this is how you get the IP address:
#psql -h $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(container_postgres)) -U postgres
# docker compose creates a network called postgresesfdw_default
connect:
	psql -h $(ip_postgres) -U postgres

# psql config file with password for postgres. See POSTGRES_PASSWORD in run.
.PHONY: pgpass
pgpass:
	cat pgpass >> ~/.pgpass
	chmod 600 ~/.pgpass
# our container needs to have python 2 for esfdw to work
check_python_version:
	docker run -it --rm $(image_name) python -V | grep 'Python 2'
# get a shell in a new container
debug:
	docker run -it --rm $(image_name) bash

# elasticsearch example data
accounts.zip:
	wget 'https://github.com/bly2k/files/blob/master/accounts.zip?raw=true' -O accounts.zip
accounts.json: accounts.zip
	test -f accounts.json || unzip accounts.zip
load_es_example_data: accounts.json
	curl -XPOST 'http://$(ip_elasticsearch):9200/bank/account/_bulk?pretty' --data-binary "@accounts.json" >/dev/null
show_es_indices:
	curl 'http://$(ip_elasticsearch):9200/_cat/indices?v'

# use FDW
# =======
psql := psql -h $(ip_postgres) -U postgres
create_extension:
	$(psql) -c "CREATE EXTENSION IF NOT EXISTS multicorn;"
create_server_es:
	$(psql) < create_server.sql

get_mapping_for_our_data:
	docker exec $(container_elasticsearch) curl localhost:9200/bank/account/_mapping > mapping.json
generate_foreign_table_create_statement:
	cat mapping.json | docker exec -i postgresesfdw_postgres_1 python -m esfdw.mapping_to_schema -i bank -d account -s es > foreign_table.sql
	# remove the last option line (column_name_translation)
	perl -pe "s/\s+column_name_translation 'true'\n//; s/ index 'bank',/ index 'bank'/" -i foreign_table.sql
create_foreign_table:
	$(psql) < foreign_table.sql
selects:
	$(psql) < selects.sql

readme:
	rst2html.py README.rst > README.html
