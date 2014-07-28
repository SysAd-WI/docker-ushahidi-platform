# Docker Container for Ushahidi Platform

A Dockerfile that installs the latest [Ushahidi Platform](https://github.com/ushahidi/platform) running on nginx and php-fpm, with a MySQL database. It will also set up OpenSSH for additional management.

## Installation

This guide assumes that you will be running Docker [without sudo](https://docs.docker.com/installation/binaries/#giving-non-root-access). Please make sure that Docker is configured properly before running any of these commands. (If you are on Mac OSX, note that Docker on OSX is automatically configured to not require `sudo`)

    $ git clone https://github.com/ushahidi/docker-ushahidi-platform.git
    $ cd docker-ushahidi-platform
    $ docker build -t="docker-ushahidi-platform" .


### On Mac OSX
If you have not previously run Docker on OSX, read the [OSX install guide](https://docs.docker.com/installation/mac/) first. Before you will be able to run any docker commands, you will need to run `boot2docker start` and then run the `export DOCKER_HOST=tcp://ip:port` command that it lists.

**Also note that ports are bound to a dynamic IP address, not `0.0.0.0`. The bridging IP address can be found by running `boot2docker ip`. Replacing `0.0.0.0` with this IP in the instructions below.**

## Usage

To spawn a new instance of ushahidi:

    $ docker run -p 80 -p 22 -d -t docker-ushahidi-platform

You'll see an ID output like `1d72c3c85840637d9d73d25818049952c0d98b64fde6b3c0d8645b08127b15e5`. This is your **container id**, which can also be shorted to 12 characters like `1d72c3c858`.

Use this ID to check the port it's on:

    $ docker port 1d72c3c858 80 # Make sure to change the ID to yours!

This command returns the container ID, which you can use to find the external port you can use to access Ushahidi Platform from your host machine:

    $ docker port <container-id> 80

You can the visit the following URL in a browser on your host machine to get started:

    http://0.0.0.0:<port>

*This address will be different if you are using OSX! See the additional instructions above.*

To get the SSH password for the `ushahidi` user so you can login and edit files, check the top of the docker container logs for it:

    $ docker logs <container-id>

### Additional Commands

To see what docker images are currently created, use the `ps` command:

    $ docker ps -a

If there are any images that are stopped and can be removed, use the `rm` command:

    $ docker rm <image-id>

If you get a warning about the image needing to be stopped, use the `stop` command first:

    $ docker stop <image-id>

For additional commands, see `docker help` and the [Docker User Guide](https://docs.docker.com/userguide/).

# Credits

This Docker container is heavily based on work by [oskarhane](https://github.com/oskarhane/docker-wordpress-nginx-ssh) and [eugeneware](https://github.com/eugeneware/docker-wordpress-nginx).
