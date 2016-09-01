image_name := postgres
container_name := test_postgres

build:
	docker build -t $(image_name) .

run:
	docker run --rm -e POSTGRES_PASSWORD=geheim --name $(container_name) $(image_name) 
connect:
	psql -h $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(container_name)) -U postgres
.PHONY: pgpass
pgpass:
	cat pgpass >> ~/.pgpass
	chmod 600 ~/.pgpass
check_python_version:
	docker run -it --rm $(image_name) python -V | grep 'Python 2'
readme:
	rst2html.py README.rst > README.html
