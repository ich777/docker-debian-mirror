FROM ich777/debian-baseimage:bullseye

LABEL maintainer="admin@minenet.at"

RUN echo "deb http://10.0.0.1:980/debian bullseye main contrib non-free" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y install apt-mirror xz-utils cron apache2 && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/10.0.0.1:980/d' /etc/apt/sources.list && \
	rm -rf /var/www/* && \
	echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
	echo "ServerTokens Prod" >> /etc/apache2/apache2.conf && \
	echo "ServerSignature Off" >> /etc/apache2/apache2.conf && \
	sed -i '/DocumentRoot.*/s//DocumentRoot \/var\/www/' /etc/apache2/sites-enabled/000-default.conf && \
	sed -i '/unstable/s//stable/' /etc/apt/mirror.list

ENV DATA_DIR="/debian-mirror"
ENV MIRROR_DIR="$DATA_DIR/data"
ENV CONFIG_DIR="$DATA_DIR/config"
ENV APACHE2_PORT=980
ENV CRON_SCHEDULE="0 1 * * *"
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
RUN chmod -R 770 /opt/scripts/

EXPOSE 980

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]