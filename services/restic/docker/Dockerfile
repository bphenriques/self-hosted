FROM alpine:latest as rclone

# Get rclone executable
ADD https://downloads.rclone.org/rclone-current-linux-amd64.zip /
RUN unzip rclone-current-linux-amd64.zip && mv rclone-*-linux-amd64/rclone /bin/rclone && chmod +x /bin/rclone

FROM restic/restic:0.18.0

# Copy rclone
COPY --from=rclone /bin/rclone /bin/rclone

RUN apk add --update --no-cache curl

VOLUME /config
VOLUME /data
VOLUME /backup-target

ENV RESTIC_CACHE_DIR="/data/.cache" \
    RCLONE_CONFIG_DIR="/config/rclone" \
    RCLONE_CONFIG="/config/rclone/rclone.conf" \
    FILES_TO_BACKUP="/backup-target" \
    RESTIC_BACKUP_ARGS="" \
    RESTIC_FORGET_POLICY="" \
    RESTIC_INIT_ARGS=""

ADD restic /etc/restic/

ENTRYPOINT ["/etc/restic/entrypoint.sh"]
