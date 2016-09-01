compose_project_name := pges
image_postgres := $(compose_project_name)_postgres
image_elasticsearch := $(compose_project_name)_elasticsearch
# docker compose convention
container_postgres := $(compose_project_name)_postgres_1
container_elasticsearch := $(compose_project_name)_elasticsearch_1
# if the containers run, those contain their IP addresses
ip_postgres := $(shell docker inspect --format '{{ .NetworkSettings.Networks.$(compose_project_name)_default.IPAddress }}' $(container_postgres) 2>/dev/null)
ip_elasticsearch := $(shell docker inspect --format '{{ .NetworkSettings.Networks.$(compose_project_name)_default.IPAddress }}' $(container_elasticsearch) 2>/dev/null)

# Command Shortcuts
# =================
compose := docker-compose --project-name $(compose_project_name)
# password is set in docker-compose.yml
psql := PGPASSWORD=foobarbaz psql -h $(ip_postgres) -U postgres

# default target
# ==============
default: compose

# used in ADD clause in Dockerfile
esfdw:
	git submodule update --init

compose:
	$(compose) up

build: esfdw
	$(compose) build

connect:
	$(psql)

# our container needs to have python 2 for esfdw to work
check_python_version:
	docker run -it --rm $(image_name) python -V | grep 'Python 2'
# get a shell in a new container
debug:
	docker run -it --rm $(image_name) bash

# Elasticsearch Example Data
# ==========================
accounts.zip:
	test -f accounts.zip || wget 'https://github.com/bly2k/files/blob/master/accounts.zip?raw=true' -O accounts.zip
accounts.json: accounts.zip
	test -f accounts.json || unzip accounts.zip
load_es_example_data: accounts.json
	curl -XPOST 'http://$(ip_elasticsearch):9200/bank/account/_bulk?pretty' --data-binary "@accounts.json" >/dev/null
show_es_indices:
	curl 'http://$(ip_elasticsearch):9200/_cat/indices?v'

# use FDW
# =======
create_extension:
	$(psql) -c "CREATE EXTENSION IF NOT EXISTS multicorn;"
create_server_es:
	$(psql) < create_server.sql
get_mapping_for_our_data:
	docker exec $(container_elasticsearch) curl localhost:9200/bank/account/_mapping > mapping.json
generate_foreign_table_create_statement:
	cat mapping.json | docker exec -i $(compose_project_name)_postgres_1 python -m esfdw.mapping_to_schema -i bank -d account -s es > foreign_table.sql
	# remove the last option line (column_name_translation)
	perl -pe "s/\s+column_name_translation 'true'\n//; s/ index 'bank',/ index 'bank'/" -i foreign_table.sql
create_foreign_table:
	$(psql) < foreign_table.sql
selects:
	$(psql) < selects.sql

readme:
	rst2html.py README.rst > README.html
