# vim:set ft=dockerfile:
FROM postgres:9.5

RUN apt-get update \
	&& apt-get install -y \
     postgresql-server-dev-9.5 \
     python-pip \
     python-dev \
  && rm -rf /var/lib/apt/lists/*

# http://pgxnclient.projects.pgfoundry.org/install.html
# http://elasticsearch-py.readthedocs.io/en/master/#compatibility
RUN pip install pgxnclient 'elasticsearch>=2.0.0,<3.0.0'

# http://multicorn.org/#idid3
RUN pgxn install multicorn
RUN pgxn install foreign_table_exposer

ADD esfdw /tmp/esfdw

WORKDIR /tmp/esfdw
RUN python setup.py install

ADD docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
