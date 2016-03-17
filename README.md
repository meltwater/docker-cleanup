# Docker Cleanup
This image will periodically clean up exited containers and remove images and volumes that aren't in use by a
running container. Based on [tutumcloud/image-cleanup](https://github.com/tutumcloud/image-cleanup) and
[chadoe/docker-cleanup-volumes](https://github.com/chadoe/docker-cleanup-volumes) with some small fixes.

**WARNING: This script will remove all exited containers, data-only containers and unused images unless you 
carefully exclude them. Take care if you mount /var/lib/docker into the container since that will clean 
up all unused data volumes. If it's not compatible with your system or Docker version it may delete 
all your volumes, even from under running containers.**

Normally any Docker containers that exit are still kept on disk until *docker rm -v* is used to clean
them up. Similarly any images that aren't used any more are kept around. For a cluster node that see
lots of containers start and stop, large amounts of exited containers and old image versions can fill
up the disk. A Jenkins build slave has the same issues, but can also suffer from SNAPSHOT images being
continuously rebuilt and causing untagged <none> images to be left around.

## Environment Variables
The default parameters can be overridden by setting environment variables on the container using the **docker run -e** flag.

 * **CLEAN_PERIOD=1800** - Interval in seconds to sleep after completing a cleaning run. Defaults to 1800 seconds = 30 minutes.
 * **DELAY_TIME=1800** - Seconds to wait before removing exited containers and unused images. Defaults to 1800 seconds = 30 minutes.
 * **KEEP_IMAGES** - List of images to avoid cleaning, e.g. "ubuntu:trusty, ubuntu:latest". Defaults to clean all unused images.
 * **KEEP_CONTAINERS** - List of images for exited or dead containers to avoid cleaning, e.g. "ubuntu:trusty, ubuntu:latest".
 * **LOOP** - Add the ability to do non-looped cleanups, run it once and exit. Options are true, false. Defaults to true to run it forever in loops.
 * **DEBUG** - Set to 1 to enable more debugging output on pattern matches

Note that **KEEP_IMAGES** and **KEEP_CONTAINERS** are left-anchored bash shell pattern matching lists (NOT regexps).  Therefore, the image **foo/bar:tag** will be matched by ANY of the following:

 * foo/bar:tag
 * foo/bar
 * foo/b
 * [[:alpha:]]/bar
 * \*/\*:tag
 * \*:tag
 * foo/\*:tag

However it will not match

 * foo/baz
 * bar:tag
 * /bar
 * :tag
 * [[:alpha:]]:tag

By default, both are set to **\*\*None\*\*** which is the same as the blank string.  If you want to keep ALL images or containers, effectively disabling this 
part of the cleanup, then you should use **\*:\*** to match all images.  Do not 
use a bare **\*** as this will be taken as a filename match.

## Deployment
The image uses the Docker client to to list and remove containers and images. For this reason the Docker client and socket is mapped into the container.

If the */var/lib/docker* directory is mapped into the container this script will also clean up orphaned Docker volumes.

### Systemd and CoreOS/Fleet

Create a [Systemd unit](http://www.freedesktop.org/software/systemd/man/systemd.unit.html) file
in **/etc/systemd/system/docker-cleanup.service** with contents like below. Using CoreOS and
[Fleet](https://coreos.com/docs/launching-containers/launching/fleet-unit-files/) then
add the X-Fleet section to schedule the unit on all cluster nodes.

```
[Unit]
Description=Cleanup of exited containers and unused images/volumes
After=docker.service
Requires=docker.service

[Install]
WantedBy=multi-user.target

[Service]
Environment=IMAGE=meltwater/docker-cleanup:latest NAME=docker-cleanup

# Allow docker pull to take some time
TimeoutStartSec=600

# Restart on failures
KillMode=none
Restart=always
RestartSec=15

ExecStartPre=-/usr/bin/docker kill $NAME
ExecStartPre=-/usr/bin/docker rm $NAME
ExecStartPre=-/bin/sh -c 'if ! docker images | tr -s " " : | grep "^${IMAGE}:"; then docker pull "${IMAGE}"; fi'
ExecStart=/usr/bin/docker run \
    -v /var/run/docker.sock:/var/run/docker.sock:rw \
    -v /var/lib/docker:/var/lib/docker:rw \
    --name=${NAME} \
    $IMAGE

ExecStop=/usr/bin/docker stop $NAME

[X-Fleet]
Global=true
```



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
      - "/var/lib/docker:/var/lib/docker:rw"
```

### Command Line
```
docker run \
  -v /var/run/docker.sock:/var/run/docker.sock:rw \
  -v /var/lib/docker:/var/lib/docker:rw \
  meltwater/docker-cleanup:latest
```

### Development

A ``Makefile`` is included to help with repetitive commands during development.

```
make help
```
