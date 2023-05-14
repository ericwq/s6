# alpine container with s6-rc or openrc support

This is an alpine container which suppport [s6](https://skarnet.org/software/s6/) or [openrc](https://github.com/OpenRC/openrc) as init system. The container need [utmps](https://git.skarnet.org/cgi-bin/cgit.cgi/utmps/about/) service and  [ssh](https://www.openssh.com/) service. The sshd service is used to support remote login. The utmps services is used to support `last` and `who` command.

I came cross s6 because `utmps` need a process supervisor. `utmps` is required because default alpine doesn't support [utmpx.h API](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/utmpx.h.html). I tried `s6` first, after several days study, it turns out to be that [s6-rc](https://skarnet.org/software/s6-rc/index.html) and [s6-overlay](https://github.com/just-containers/s6-overlay) is what I need for container. With the help from [utmps document](https://git.skarnet.org/cgi-bin/cgit.cgi/utmps/tree/examples/s6-rc), I built a `s6-rc` container for `utmps`. Eventually, s6-rc container has all the required packages, except the utmps init script. That means the container cant't support `last` and `who` command, even if the container has all the necessary services.

`openrc` is the next effort. Got a clue from this [post](https://gitlab.alpinelinux.org/alpine/aports/-/issues/13659). Then a [dockerfile](https://github.com/dockage/alpine/blob/main/3.17/Dockerfile) in github.com help me to build the `openrc` container. This time the container can support `last` and `who` command.

Compare s6-rc container and openrc container, `utmps-openrc` package is the key to provide init script for openrc container. Maybe you can find the solution from the `utmps-openrc` package. The following is the content of `utmps-openrc`:

<details><summary>utmps-openrc package</summary><p>

```sh
openrc-ssh:/etc/init.d# apk info -a utmps-openrc
utmps-openrc-0.1.2.1-r1 description:
A secure utmp/wtmp implementation (OpenRC init scripts)

utmps-openrc-0.1.2.1-r1 webpage:
https://skarnet.org/software/utmps/

utmps-openrc-0.1.2.1-r1 installed size:
32 KiB

utmps-openrc-0.1.2.1-r1 depends on:

utmps-openrc-0.1.2.1-r1 provides:

utmps-openrc-0.1.2.1-r1 is required by:

utmps-openrc-0.1.2.1-r1 contains:
etc/init.d/btmpd
etc/init.d/utmp-init
etc/init.d/utmp-prepare
etc/init.d/utmpd
etc/init.d/wtmpd

utmps-openrc-0.1.2.1-r1 triggers:

utmps-openrc-0.1.2.1-r1 has auto-install rule:
openrc
utmps=0.1.2.1-r1

utmps-openrc-0.1.2.1-r1 affects auto-installation of:

utmps-openrc-0.1.2.1-r1 replaces:

utmps-openrc-0.1.2.1-r1 license:
ISC
```

</p></details>

If you check the `utmps-openrc` package, you will find the `utmp-init`, `utmp-prepare` script.

I don't have enough time to research all available init system. There is some articles to compare the init systems: 
- [A new service manager for Linux distributions](https://skarnet.com/projects/service-manager.html)
- [Why another supervision suite ?](https://skarnet.org/software/s6/why.html)
- [Why s6-rc ?](https://skarnet.org/software/s6-rc/why.html)
- [Comparison of init systems](https://wiki.gentoo.org/wiki/Comparison_of_init_systems)
- [systemd bad for dev and gentoo?](https://forums.gentoo.org/viewtopic-t-994548.html).

## openrc container

This container use `openrc` as the init system. It also support utmpd, wtmpd and sshd service on boot.

### usage

Run the following command to build the openrc container.

```sh
% docker build --build-arg ROOT_PWD=passowrd \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t openrc-ssh:0.1.0 -f openrc.dockerfile .
```

Run the following command to start the container.

```sh
% docker run --env TZ=Asia/Shanghai --tty --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -h openrc-ssh --name openrc-ssh -d -p 5022:22 openrc-ssh:0.1.0
```

Run the following command to login in to the container.

```sh
% rm ~/.ssh/known_hosts ~/.ssh/known_hosts.old
% ssh -p 5022 root@localhost
```

Login in to the container and run `setup-utmp` init script for utmps. unfortunately I can't find the right way to run `setup-utmp` at building image time.

```sh
% setup-utmp
```

Finally, you need to reboot the container and login in again. Now you can run `who` and `last` command.

```sh
openrc-ssh:/etc/init.d# who
root            pts/1           00:00   May 13 18:46:42  172.17.0.1
openrc-ssh:/etc/init.d# last
USER       TTY            HOST               LOGIN        TIME
ide        pts/2          172.17.0.1         May 13 18:47
root       pts/1          172.17.0.1         May 13 18:46
reboot     system boot    5.15.49-linuxkit   May 13 18:47
```

You can check the init system and required services with the following command.

```sh
openrc-ssh:/etc/init.d# pstree -p
init(1)-+-s6-ipcserverd(154)
        |-s6-ipcserverd(217)
        |-s6-ipcserverd(245)
        `-sshd(190)---sshd(286)---ash(288)---pstree(338)
```

## s6-rc container

### usage

check the `build.md` for how to build image and run container.

### the relationship between s6 and s6-overlay

`s6` is the base, it is best used in virtual machine environment instead of docker container. `s6-overlay` is the `s6` wrapper for docker container environment.

### installation via package or tar ball

Alpine and other linux distribution support `s6` related package. For example, on alpine there are full set of `s6` package available.

<details><summary>s6 related package in alpine</summary><p>

```sh
# apk search s6
s6-portable-utils-2.3.0.2-r1
s6-networking-2.5.1.3-r1
s6-2.11.3.2-r1
s6-rc-0.5.4.1-r1
s6-dns-doc-2.3.5.5-r1
s6-dns-2.3.5.5-r1
s6-dns-dev-2.3.5.5-r1
s6-ipcserver-2.11.3.2-r1
s6-portable-utils-doc-2.3.0.2-r1
s6-linux-utils-2.6.1.2-r1
s6-networking-man-pages-2.5.1.3.3-r0
s6-overlay-helpers-0.1.0.1-r0
s6-linux-init-static-1.1.1.1-r0
s6-openrc-2.11.3.2-r1
s6-linux-init-1.1.1.1-r0
s6-rc-doc-0.5.4.1-r1
s6-networking-dev-2.5.1.3-r1
s6-dns-static-2.3.5.5-r1
s6-overlay-doc-3.1.5.0-r0
s6-dev-2.11.3.2-r1
s6-overlay-3.1.5.0-r0
s6-doc-2.11.3.2-r1
s6-static-2.11.3.2-r1
s6-linux-init-doc-1.1.1.1-r0
s6-linux-utils-doc-2.6.1.2-r1
s6-networking-static-2.5.1.3-r1
s6-man-pages-2.11.3.2.4-r0
s6-rc-static-0.5.4.1-r1
s6-overlay-syslogd-3.1.5.0-r0
s6-rc-man-pages-0.5.4.1.2-r0
s6-linux-init-man-pages-1.1.1.0.1-r0
s6-portable-utils-man-pages-2.3.0.2.2-r0
s6-rc-dev-0.5.4.1-r1
s6-linux-init-dev-1.1.1.1-r0
s6-networking-doc-2.5.1.3-r1
```

</p></details>

While the origianl `s6-overlay` site suggest `tar.xz` installation. Such as:

```dockerfile
# extract s6-overlay
#
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/s6/
RUN tar xf /tmp/s6/s6-overlay-noarch.tar.xz -C /
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp/s6/
RUN tar xf /tmp/s6/s6-overlay-x86_64.tar.xz -C /
RUN rm -rf /tmp/s6
```
For alpine, `s6-overlay` package is more convinient for us. The following docker command is much more simple.

```dockerfile
RUN apk add --no-cache --update openssh-server s6-overlay
```

### sshd problem

`s6-overlay` support running `sshd` as supervised process in the follwoing way. In this way, the container will execute `ENTRYPOINT` first, then the system will execute `CMD` part.

```dockerfile
CMD ["/usr/sbin/sshd", "-D"]

# start s6-overlay
#
ENTRYPOINT ["/init"]
```

### PATH problem

With the tar ball installation, the `s6-overlay` is installed under `/command` and `/package` directory. utmps give an example `s6-rc` configuration. You need to change shebangs line to respect the above installation.

The origianl content of `utmpd/run` script:

```sh
#!/bin/execlineb -P

fdmove -c 2 1
s6-setuidgid utmp
cd /run/utmps
fdmove 1 3
s6-ipcserver -1 -- /run/utmps/utmpd-socket
utmps-utmpd
```
The modified content of `utmpd/run` script, keep your eye on the first shebangs line. Without the modification, your run script is not executeable.

```sh
#!/command/execlineb -P

fdmove -c 2 1
s6-setuidgid utmp
cd /run/utmps
fdmove 1 3
s6-ipcserver -1 -- /run/utmps/utmpd-socket
utmps-utmpd
```
### reference

- [s6-example](https://github.com/beldpro-ci/s6-entrypoint)
- [Docker and S6 – My New Favorite Process Supervisor](https://tutumcloud.wordpress.com/2014/12/02/docker-and-s6-my-new-favorite-process-supervisor/)
- [Building a skarnet.org s6 Init System](https://danmc.net/posts/s6-1/)
- [Quickstart and FAQ for s6-linux-init](http://skarnet.org/software/s6-linux-init/quickstart.html)
- [An overview of s6](https://skarnet.org/software/s6/overview.html)
- [s6 overlay](https://github.com/just-containers/s6-overlay)
- [S6 Made Easy, with the S6 Overlay](https://tutumcloud.wordpress.com/2015/05/20/s6-made-easy-with-the-s6-overlay/)
- [How to understand S6 Overlay v3](https://darkghosthunter.medium.com/how-to-understand-s6-overlay-v3-95c81c04f075)
