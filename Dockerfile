FROM ich777/debian-baseimage:bullseye

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install apt-mirror xz-utils cron && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/debian-mirror"
ENV MIRROR_DIR="$DATA_DIR/data"
ENV CONFIG_DIR="$DATA_DIR/config"
ENV UID=99
ENV GID=100
ENV UMASK=0000
ENV DATA_PERM=770
ENV USER="debian"
RUN mkdir -p $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
COPY /cron /tmp/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]