# Folding@Home Client for Docker using AMD GPU ####

This project builds a Docker image for running the [Folding@Home](https://foldingathome.org/) Client in headless mode as a Docker Container with access to the host system's AMD GPU.  By design, this container does GPU only folding (no CPU folding).

Specifically this has been tested on my environment:
* Arch Linux host with 5.6.7 kernel
* AMD RX 580 GPU with open source `amdgpu` kernel driver on the host

## Building the docker image locally
```sh
make
```
Optionally, you can confirm that an image was built locally with this:
```sh
docker image ls --filter reference=fah-amdgpu
```

## Running
To run the container image as a Docker container to do some folding
* Here we are bind mounting a `config.xml` file into the container.
* Specifically not starting the container with the `--rm` flag since F@H work units
can be resumed as they save state checkpoints to disk. So we want
to be able to resume a container should we have to stop it for
unrelated reasons (like a reboot).

```sh
docker run -d \
--device=/dev/dri \
--security-opt seccomp=unconfined \
-v `pwd`/config.xml:/home/fah/config.xml:ro \
--name fah \
fah
```

## Monitoring
```
docker logs -f fah
```

## Suspending folding
```
docker stop fah
```

## Resuming folding
```
docker start fah
```

## Purge/cleanup
Warning: F@H uses checkpoints to save progress on folding Work Units (WU) and credit for work is only granted at completion of the WU. Removing the container will wipe out checkpoints, so whatever progress was made on current WUs will be lost.
```
docker rm -f fah
```

## Performance, Power, Fan Noise, and Heat
With GPU folding, there don't seem to be good F@H client options for throttling usage.

This is not a problem though, since in practice it's more elegant to just set a TDP (power) cap for your AMD GPU.

My RX 580 has a default power cap of 135 W.  The power cap can be changed dynamically via sysfs without any special tools.

Example: To change the power cap to 50 W (50,000,000 μW)
```sh
# (As root)
echo 50000000 > /sys/class/drm/card0/device/hwmon/hwmon1/power1_cap
```

You may find it useful to install the `rocm-smi` tool to check current power use.


## Troubleshooting
To get an interactive shell to poke around:
```sh
docker run --rm -it --device=/dev/dri --security-opt seccomp=unconfined fah-amdgpu bash
```
Useful commands from the interactive container ...
* List OpenCL devices
```
clinfo -l
```
* Check Folding@Home Client configuration (mostly looking for it to show GPU count > 0)
```
FAHClient --info
```
