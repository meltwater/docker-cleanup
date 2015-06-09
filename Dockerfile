FROM alpine:latest

# run.sh script uses some bash specific syntax
RUN apk add --update bash

# Install cleanup script
ADD run.sh /run.sh

ENV CLEAN_PERIOD **None**
ENV DELAY_TIME **None**
ENV KEEP_IMAGES **None**

ENTRYPOINT ["/run.sh"]
