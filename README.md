# Debian-APT-Mirror Docker optimized for Unraid
This container will run apt-mirror and Apache2. This allows you to create a local apt mirror for Debian packages.

On the first run you will have to edit the mirror.list that lives in your CONFIG_DIR which repositories you want to sync and eventually other settings like the threads to use for downloading,... and restart the container (keep an eye on the logs the container will tell you what to do).

**ATTENTION/WARNING:** Keep in mind that the first sync can take very long depending on how much repositories you've selected to sync (stable main contrib non-free: Will need about 200GB of hard drive space!).

**Update from the mirror files:** By default a cron job will run every day at 1am that will run apt-mirror and update your mirror.

**Mirror address:** The default address for the mirror is 'http://ipFROMtheCONTAINER:980'
Add something like this to your '/etc/apt/sources.list': 'deb http://ipFROMtheCONTAINER:980/debian stable main contrib non-free' <- without quotes
(please edit 'ipFROMtheCONTAINER', port and also the repositories to match your config)

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Base directory | /debian-mirror |
| CONFIG_DIR | Folder for configfiles (mirror.list & cron) | $DATA_DIR/config |
| MIRROR_DIR | Folder for the mirror data | $DATA_DIR/data |
| APACHE2_PORT | Set which port in the container to use for Apache2 | 980 |
| CRON_SCHEDULE | Cron schedule. Default: every day at 1am | 0 1 * * * |
| FORCE_UPDATE | Force update from mirror on every start/restart of the container | false |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value for new created files | 0000 |
| DATA_PERMS | Data permissions for config folder | 770 |

## Run example
```
docker run --name Debian-Mirror -d \
	-p 980:980 \
	--env 'APACHE2_PORT=980' \
	--env 'CRON_SCHEDULE=0 1 * * *' \
	--env 'FORCE_UPDATE=false' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=0000' \
	--env 'DATA_PERMS=770' \
	--volume /mnt/cache/appdata/debian-mirror/data:/debian-mirror/data \
	--volume /mnt/cache/appdata/debian-mirror/config:/debian-mirror/config \
	ich777/debian-mirror
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!
 
#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/