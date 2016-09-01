build:
	docker build -t postgres .

container_name := test_postgres
run:
	docker run --rm -e POSTGRES_PASSWORD=geheim --name $(container_name) postgres 
connect:
	psql -h $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(container_name)) -U postgres
.PHONY: pgpass
pgpass:
	cat pgpass >> ~/.pgpass
	chmod 600 ~/.pgpass
readme:
	rst2html.py README.rst > README.html
