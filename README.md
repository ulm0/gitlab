# GitLab CE for ARM

[![pipeline status](https://gitlab.com/ulm0/gitlab/badges/master/pipeline.svg)](https://gitlab.com/ulm0/gitlab/commits/master) [![](https://images.microbadger.com/badges/version/ulm0/gitlab.svg)](https://microbadger.com/images/ulm0/gitlab "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/ulm0/gitlab.svg)](https://microbadger.com/images/ulm0/gitlab "Get your own image badge on microbadger.com") [![Docker Pulls](https://img.shields.io/docker/pulls/ulm0/gitlab.svg)](https://hub.docker.com/r/ulm0/gitlab/)

GitLab CE for ARM is in Docker Hub:

- [ulm0/gitlab](https://hub.docker.com/r/ulm0/gitlab/)

The GitLab Docker image is a monolithic image of GitLab running all the necessary services on a single container.

GitLab only offers the Community Edition for Raspbery Pi, the Docker image is based on this one; in addition, only stable builds are containerized.

The GitLab Docker image can be run in multiple ways:

- [Run the image in Docker Engine](#run-the-image)
- [Install GitLab using docker-compose](#install-gitlab-using-docker-compose)

<!-- - [Install GitLab into a cluster](#install-gitlab-into-a-cluster) -->

## Prerequisites

Docker installation is required, see the [official installation docs](https://docs.docker.com/engine/installation/).

## Run the image

Run the image:

```bash
docker run -d \
--hostname gitlab.example.com \
-p 443:443 -p 80:80 -p 22:22 \
--name gitlab \
--restart always \
-v /srv/gitlab/config:/etc/gitlab \
-v /srv/gitlab/logs:/var/log/gitlab \
-v /srv/gitlab/data:/var/opt/gitlab \
ulm0/gitlab
```

This will download and start a GitLab CE container and publish ports needed to
access SSH, HTTP and HTTPS. All GitLab data will be stored as subdirectories of
`/srv/gitlab/`. The container will automatically `restart` after a system reboot.

You can now login to the web interface as explained in
[After starting a container](#after-starting-a-container).

If you are on *SELinux* then run this instead:

```bash
docker run -d \
--hostname gitlab.example.com \
-p 443:443 -p 80:80 -p 22:22 \
--name gitlab \
--restart always \
-v /srv/gitlab/config:/etc/gitlab:Z \
-v /srv/gitlab/logs:/var/log/gitlab:Z \
-v /srv/gitlab/data:/var/opt/gitlab:Z \
ulm0/gitlab
```

This will ensure that the Docker process has enough permissions to create the
config files in the mounted volumes.

## Where is the data stored?

The GitLab container uses host mounted volumes to store persistent data:

| Local location | Container location | Usage |
| -------------- | ------------------ | ----- |
| `/srv/gitlab/data`  | `/var/opt/gitlab` | For storing application data |
| `/srv/gitlab/logs`  | `/var/log/gitlab` | For storing logs |
| `/srv/gitlab/config`| `/etc/gitlab`     | For storing the GitLab configuration files |

You can fine tune these directories to meet your requirements.

## Configure GitLab

This container uses the official Omnibus GitLab package, so all configuration
is done in the unique configuration file `/etc/gitlab/gitlab.rb`.

To access GitLab's configuration file, you can start a shell session in the
context of a running container. This will allow you to browse all directories
and use your favorite text editor:

```bash
docker exec -it gitlab /bin/bash
```

You can also just edit `/etc/gitlab/gitlab.rb`:

```bash
docker exec -it gitlab vi /etc/gitlab/gitlab.rb
```

Once you open `/etc/gitlab/gitlab.rb` make sure to set the `external_url` to
point to a valid URL.

To receive e-mails from GitLab you have to configure the
[SMTP settings](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/doc/settings/smtp.md) because the GitLab Docker image doesn't
have an SMTP server installed.

You may also be interested in [Enabling HTTPS](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/doc/settings/nginx.md#enable-https).

After you make all the changes you want, you will need to restart the container
in order to reconfigure GitLab:

```bash
docker restart gitlab
```

_**Note:** GitLab will reconfigure itself whenever the container starts._

For more options about configuring GitLab please check the
[Omnibus GitLab documentation](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/doc/settings/configuration.md).

### Pre-configure Docker container

You can pre-configure the GitLab Docker image by adding the environment
variable `GITLAB_OMNIBUS_CONFIG` to docker run command. This variable can
contain any `gitlab.rb` setting and will be evaluated before loading the
container's `gitlab.rb` file. That way you can easily configure GitLab's
external URL, make any database configuration or any other option from the
[Omnibus GitLab template](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/files/gitlab-config-template/gitlab.rb.template).

_Note: The settings contained in `GITLAB_OMNIBUS_CONFIG` will not be written to the `gitlab.rb` configuration file, they're evaluated on load._

Here's an example that sets the external URL and enables LFS while starting
the container:

```bash
docker run -d \
--hostname gitlab.example.com \
--env GITLAB_OMNIBUS_CONFIG="external_url 'http://my.domain.com/'; gitlab_rails['lfs_enabled'] = true;" \
-p 443:443 -p 80:80 -p 22:22 \
--name gitlab \
--restart always \
-v /srv/gitlab/config:/etc/gitlab \
-v /srv/gitlab/logs:/var/log/gitlab \
-v /srv/gitlab/data:/var/opt/gitlab \
ulm0/gitlab
```

Note that every time you execute a `docker run` command, you need to provide
the `GITLAB_OMNIBUS_CONFIG` option. The content of `GITLAB_OMNIBUS_CONFIG` is
_not_ preserved between subsequent runs.

There are also a limited number of environment variables to configure GitLab.
They are documented in the [environment variables section of the GitLab documentation](https://docs.gitlab.com/ce/administration/environment_variables.html).

## After starting a container

After starting a container you can visit <http://localhost/> or
<http://192.168.59.103> if you use boot2docker. It might take a while before
the Docker container starts to respond to queries.

The very first time you visit GitLab, you will be asked to set up the admin
password. After you change it, you can login with username `root` and the
password you set up.

## Upgrade GitLab to newer version

To upgrade GitLab to a new version you have to:

1. Stop the running container:

    ```bash
    docker stop gitlab
    ```

2. Remove existing container:

    ```bash
    docker rm gitlab
    ```

3. Pull the new image:

    ```bash
    docker pull ulm0/gitlab
    ```

4. Create the container once again with previously specified options:

    ```bash
    docker run -d \
    --hostname gitlab.example.com \
    -p 443:443 -p 80:80 -p 22:22 \
    --name gitlab \
    --restart always \
    -v /srv/gitlab/config:/etc/gitlab \
    -v /srv/gitlab/logs:/var/log/gitlab \
    -v /srv/gitlab/data:/var/opt/gitlab \
    ulm0/gitlab
    ```

On the first run, GitLab will reconfigure and update itself.

### Use tagged versions of GitLab

We provide tagged versions of GitLab Docker images.

To see all available tags check:

- [GitLab tags](https://hub.docker.com/r/ulm0/gitlab/tags/)

To use a specific tagged version, replace `ulm0/gitlab` with
the GitLab version you want to run, for example `ulm0/gitlab:10.3.3-ce`.

### Run GitLab CE on public IP address

You can make Docker to use your IP address and forward all traffic to the
GitLab CE container by modifying the `-p` flag.

To expose GitLab CE on IP 1.1.1.1:

```bash
docker run -d \
--hostname gitlab.example.com \
-p 1.1.1.1:443:443 \
-p 1.1.1.1:80:80 \
-p 1.1.1.1:22:22 \
--name gitlab \
--restart always \
-v /srv/gitlab/config:/etc/gitlab \
-v /srv/gitlab/logs:/var/log/gitlab \
-v /srv/gitlab/data:/var/opt/gitlab \
ulm0/gitlab
```

You can then access your GitLab instance at `http://1.1.1.1/` and `https://1.1.1.1/`.

### Expose GitLab on different ports

GitLab will occupy by default the following ports inside the container:

- `80` (HTTP)
- `443` (if you configure HTTPS)
- `8080` (used by Unicorn)
- `22` (used by the SSH daemon)

> **Note:**
The format for publishing ports is `hostPort:containerPort`. Read more in
Docker's documentation about [exposing incoming ports][docker-ports].

> **Warning:**
Do NOT use port `8080` otherwise there will be conflicts. This port is already
used by Unicorn that runs internally in the container.

If you want to use a different port than `80` (HTTP) or `443` (HTTPS) for the
container, you need to add a separate `-p` directive to the `docker run`
command.

For example, to expose the web interface on port `8929`, and the SSH service on
port `2289`, use the following `docker run` command:

```bash
docker run -d \
--hostname gitlab.example.com \
-p 8929:80 -p 2289:22 \
--name gitlab \
--restart always \
-v /srv/gitlab/config:/etc/gitlab \
-v /srv/gitlab/logs:/var/log/gitlab \
-v /srv/gitlab/data:/var/opt/gitlab \
ulm0/gitlab
```

You then need to appropriately configure `gitlab.rb`:

1. Set `external_url`:

    ```sh
    # For HTTP
    external_url "http://gitlab.example.com:8929"

    or

    # For HTTPS (notice the https)
    external_url "https://gitlab.example.com:8929"
    ```

    For more information see the [NGINX documentation](https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/doc/settings/nginx.md).

2. Set `gitlab_shell_ssh_port`:

    ```rb
    gitlab_rails['gitlab_shell_ssh_port'] = 2289
    ```

Following the above example you will be able to reach GitLab from your
web browser under `<hostIP>:8929` and push using SSH under the port `2289`.

A `docker-compose.yml` example that uses different ports can be found in the
[docker-compose](#install-gitlab-using-docker-compose) section.

## Diagnose potential problems

Read container logs:

```bash
docker logs gitlab
```

Enter running container:

```bash
docker exec -it gitlab /bin/bash
```

From within the container you can administer the GitLab container as you would
normally administer an
[Omnibus installation](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md)

## Install GitLab using docker-compose

With [Docker compose] you can easily configure, install, and upgrade your
Docker-based GitLab installation.

1. [Install][install-compose] Docker Compose
1. Create a `docker-compose.yml` file (or [download an example][down-yml]):

    ```yaml
    web:
      image: 'ulm0/gitlab'
      restart: always
      hostname: 'gitlab.example.com'
      environment:
        GITLAB_OMNIBUS_CONFIG: |
          external_url 'https://gitlab.example.com'
          # Add any other gitlab.rb configuration here, each on its own line
      ports:
        - '80:80'
        - '443:443'
        - '22:22'
      volumes:
        - '/srv/gitlab/config:/etc/gitlab'
        - '/srv/gitlab/logs:/var/log/gitlab'
        - '/srv/gitlab/data:/var/opt/gitlab'
    ```

1. Make sure you are in the same directory as `docker-compose.yml` and run
  `docker-compose up -d` to start GitLab

Read ["Pre-configure Docker container"](#pre-configure-docker-container) to see
how the `GITLAB_OMNIBUS_CONFIG` variable works.

Below is another `docker-compose.yml` example with GitLab running on a custom
HTTP and SSH port. Notice how the `GITLAB_OMNIBUS_CONFIG` variables match the
`ports` section:

```yaml
web:
  image: 'ulm0/gitlab'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://gitlab.example.com:9090'
      gitlab_rails['gitlab_shell_ssh_port'] = 2224
  ports:
    - '9090:9090'
    - '2224:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```

This is the same as using `-p 9090:9090 -p 2224:22`.

## Update GitLab using Docker compose

Provided you [installed GitLab using docker-compose](#install-gitlab-using-docker-compose),
all you have to do is run `docker-compose pull` and `docker-compose up -d` to
download a new release and upgrade your GitLab instance.

<!-- ## Install GitLab into a cluster

The GitLab Docker images can also be deployed to various container scheduling platforms.

- Kubernetes using the [GitLab Helm Charts](https://docs.gitlab.com/ce/install/kubernetes/).
- Mesosphere DC/OS using the [DC/OS Package](https://github.com/dcos/examples/tree/master/gitlab/1.8).
- Docker Cloud using the [docker-compose config](#install-gitlab-using-docker-compose). -->

## Troubleshooting

### 500 Internal Error

When updating the Docker image you may encounter an issue where all paths
display the infamous **500** page. If this occurs, try to run
`docker restart gitlab` to restart the container and rectify the issue.

### Permission problems

When updating from older GitLab Docker images you might encounter permission
problems. This happens due to a fact that users in previous images were not
preserved correctly. There's script that fixes permissions for all files.

To fix your container, simply execute `update-permissions` and restart the
container afterwards:

```bash
docker exec gitlab update-permissions
docker restart gitlab
```

[docker compose]: https://docs.docker.com/compose/
[install-compose]: https://docs.docker.com/compose/install/
[down-yml]: https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/docker/docker-compose.yml
[docker-ports]: https://docs.docker.com/engine/reference/run/#/expose-incoming-ports

### Linux ACL issues

If you are using file ACLs on the docker host, the `docker`[^1] group requires full access to the volumes in order for GitLab to work.

```bash
$ getfacl /srv/gitlab
# file: /srv/gitlab
# owner: XXXX
# group: XXXX
user::rwx
group::rwx
group:docker:rwx
mask::rwx
default:user::rwx
default:group::rwx
default:group:docker:rwx
default:mask::rwx
default:other::r-x
```

If these are not correct, set them with:

```sh
$ sudo setfacl -mR default:group:docker:rwx /srv/gitlab
```

[^1]: `docker` is the default group, if you've changed this, update your commands accordingly.

### Getting help

If your problem is not listed here please see [getting help](https://about.gitlab.com/getting-help/) for the support channels.

These docker images are not officially supported by GitLab Inc. still efforts are made to keep them up to date.