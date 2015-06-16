# Docker Cleanup
This image will periodically clean up exited containers and remove images that aren't in use by a running container. Based on [tutumcloud/image-cleanup](https://github.com/tutumcloud/image-cleanup) with some small fixes.

Normally any Docker containers that exit are still kept on disk until *docker rm -v* is used to clean them up. Similarly any images that aren't used any more are kept around. For a cluster node that see lots of containers start and stop, large amounts of exited containers and old image versions can fill up the disk. A Jenkins build slave has the same issues, but can also suffer from SNAPSHOT images being continuously rebuilt and causing untagged <none> images to be left around.

## Environment Variables
The default parameters can be overridden by setting environment variables on the container using the **docker run -e** flag.

 * **CLEAN_PERIOD=1800** - Interval in seconds to sleep after completing a cleaning run. Defaults to 1800 seconds = 30 minutes.
 * **DELAY_TIME=1800** - Seconds to wait before removing exited containers and unused images. Defaults to 1800 seconds = 30 minutes.
 * **KEEP_IMAGES** - List of images to avoid cleaning, e.g. "ubuntu:trusty, ubuntu:latest". Defaults to clean all unused images.

## Deployment
The image uses the Docker client to to list and remove containers and images. For this reason the Docker client and socket is mapped into the container.

### Puppet Hiera

Using the [garethr-docker](https://github.com/garethr/garethr-docker) module

```
classes:
  - docker::run_instance

docker::run_instance:
  'cleanup':
    image: 'meltwater/docker-cleanup:latest'
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:rw"
```

### Command Line
```
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  meltwater/docker-cleanup:latest
```
