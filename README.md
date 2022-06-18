# Flicd in a container

This is a container image of the official Shortcut Labs AB `flicd` daemon that
can be used with things like the Home Assistant Flic integration.

## Usage

The following example command will start a container named `flicd` in the background
that will automatically restart on failure or if the host reboots:

```shell
docker run -d \
  --name flicd \
  --restart=always \
  --net=host \
  --privileged \
  -v ./data:/data \
  djelibeybi/flicd
```

Change `./data:/data` to map to a local directory in which `flicd` will store the
button registration database. If not specified, Docker will automatically create
a volume to store this database.
