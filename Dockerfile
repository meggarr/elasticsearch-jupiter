FROM openjdk:8u131-jre
MAINTAINER Richard Meng <rmeng@calix.com>

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV ES_VERSION 2.4.5

# Install Elasticsearch.
RUN groupadd --gid 1000 es \
	&& useradd --uid 1000 --gid es --shell /bin/bash --create-home es \
	&& ( curl -Lskj https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.tar.gz | \
	     gunzip -c - | tar xf - ) \
	&& mv /elasticsearch-$ES_VERSION /es \
	&& rm -rf $(find /es | egrep "(\.(exe|bat)$|sigar/.*(dll|winnt|x86-linux|solaris|ia64|freebsd|macosx))")

RUN apt-get update -y \
	&& apt-get install -y --no-install-recommends procps \
	&& apt-get -y autoremove \
	&& apt-get -y clean \
	&& apt-get -y autoclean \
	&& rm -rf /var/lib/apt/lists/*

# Install plugins
ENV PATH /es/bin:$PATH
RUN /es/bin/plugin install delete-by-query

# Volume for Elasticsearch data
RUN mkdir -p /data && chown -R es:es "/data"
VOLUME ["/data"]

# Copy configuration
COPY config /es/config

# Copy run script
COPY entrypoint.sh /

WORKDIR /es

# Set environment variables defaults
ENV ES_HEAP_SIZE 512m
ENV CLUSTER_NAME elasticsearch-jupiter
ENV NODE_MASTER true
ENV NODE_DATA true
ENV HTTP_ENABLE true
ENV NETWORK_HOST 0.0.0.0
ENV HTTP_CORS_ENABLE true
ENV HTTP_CORS_ALLOW_ORIGIN *
ENV ZEN_HOSTS ""
ENV NUMBER_OF_MASTERS 1
ENV NUMBER_OF_SHARDS 1
ENV NUMBER_OF_REPLICAS 0

# Export HTTP & Transport
EXPOSE 9200 9300

ENTRYPOINT ["/entrypoint.sh"]
CMD ["elasticsearch"]

