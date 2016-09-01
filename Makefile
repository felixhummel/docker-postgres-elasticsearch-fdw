image_name := pg_es_fdw
# docker compose convention
container_name := postgresesfdw_postgres_1

default: build

# used in ADD clause in Dockerfile
esfdw:
	git submodule update --init

build: esfdw
	docker build -t $(image_name) .

run:
	docker run --rm -e POSTGRES_PASSWORD=geheim --name $(container_name) $(image_name) 

# if started via run, this is how you get the IP address:
#psql -h $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(container_name)) -U postgres
# docker compose creates a network called postgresesfdw_default
connect:
	psql -h $(shell docker inspect --format '{{ .NetworkSettings.Networks.postgresesfdw_default.IPAddress }}' $(container_name)) -U postgres

.PHONY: pgpass
pgpass:
	cat pgpass >> ~/.pgpass
	chmod 600 ~/.pgpass
check_python_version:
	docker run -it --rm $(image_name) python -V | grep 'Python 2'
debug:
	docker run -it --rm $(image_name) bash
readme:
	rst2html.py README.rst > README.html
