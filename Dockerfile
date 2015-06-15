FROM centos:7

# Install cleanup script
ADD run.sh /run.sh

ENV CLEAN_PERIOD **None**
ENV DELAY_TIME **None**
ENV KEEP_IMAGES **None**

ENTRYPOINT ["/run.sh"]
