FROM alpine:latest

ENTRYPOINT ["/run.sh"]

ENV CLEAN_PERIOD=**None** \
    DELAY_TIME=**None** \
    KEEP_IMAGES=**None** \
    KEEP_CONTAINERS=**None** \
    LOOP=true \
    DEBUG=0

# run.sh script uses some bash specific syntax
RUN apk add --update bash docker grep

# Install cleanup script
ADD docker-cleanup-volumes.sh /docker-cleanup-volumes.sh
ADD run.sh /run.sh

