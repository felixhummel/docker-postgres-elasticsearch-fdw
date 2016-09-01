compose_project_name := pges
# compose naming conventions
image_postgres := $(compose_project_name)_postgres
image_elasticsearch := $(compose_project_name)_elasticsearch
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

# Basics
# ======
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
usage/accounts.zip:
	test -f accounts.zip || wget 'https://github.com/bly2k/files/blob/master/accounts.zip?raw=true' -O usage/accounts.zip
usage/accounts.json: usage/accounts.zip
	test -f usage/accounts.json || (cd usage/ && unzip accounts.zip)
load_es_example_data: usage/accounts.json
	curl -XPOST 'http://$(ip_elasticsearch):9200/bank/account/_bulk?pretty' --data-binary "@usage/accounts.json" >/dev/null
show_es_indices:
	curl 'http://$(ip_elasticsearch):9200/_cat/indices?v'

# use FDW
# =======
1_create_extension:
	$(psql) < usage/1_create_extension.sql
2_create_server_es:
	$(psql) < usage/2_create_server.sql
usage/mapping.json:
	docker exec $(container_elasticsearch) curl localhost:9200/bank/account/_mapping > usage/mapping.json
usage/3_foreign_table.sql: usage/mapping.json
	cat usage/mapping.json | docker exec -i $(compose_project_name)_postgres_1 python -m esfdw.mapping_to_schema -i bank -d account -s es > usage/3_foreign_table.sql
	# remove the last option line (column_name_translation)
	perl -pe "s/\s+column_name_translation 'true'\n//; s/ index 'bank',/ index 'bank'/" -i usage/3_foreign_table.sql
3_create_foreign_table:
	$(psql) < usage/3_foreign_table.sql
4_selects:
	$(psql) < usage/4_selects.sql

readme:
	rst2html.py README.rst > README.html
