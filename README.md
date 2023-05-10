# s6-overlay
A practical docker image based on [s6-overlay](https://github.com/just-containers/s6-overlay), [ssh](https://www.openssh.com/), [utmps](https://git.skarnet.org/cgi-bin/cgit.cgi/utmps/about/).

## the relationship between s6 and s6-overlay

s6 is the base, it is best used in virtual machine instead of docker container. s6-overlay is the s6 wrapper for docker container.

## installation: package vs tar ball

alpine and other linux distribution support s6 related package. for example, on alpine there are full set of s6 package available.

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
while the origianl s6-overlay site suggest `tar.xz` installation. such as:

```dockerfile
# extract s6-overlay
#
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/s6/
RUN tar xf /tmp/s6/s6-overlay-noarch.tar.xz -C /
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp/s6/
RUN tar xf /tmp/s6/s6-overlay-x86_64.tar.xz -C /
RUN rm -rf /tmp/s6
```

## sshd problem

s6-overlay support running sshd as supervised process in the follwoing way. In this way, the container will execute `ENTRYPOINT` first, then the system will execute `CMD` part.

```dockerfile
CMD ["/usr/sbin/sshd", "-D"]

# start s6-overlay
#
ENTRYPOINT ["/init"]
```

## PATH problem

With the tar ball installation, the s6-overlay is installed under `/command` and `/package` directory. utmps give an example `s6-rc` configuration. You need to change shebangs line to respect the above installation.

the origianl content of `utmpd/run` script:

```sh
#!/bin/execlineb -P

fdmove -c 2 1
s6-setuidgid utmp
cd /run/utmps
fdmove 1 3
s6-ipcserver -1 -- /run/utmps/utmpd-socket
utmps-utmpd
```
the modified content of `utmpd\run` script, keep your eye on the first shebangs line.

```sh
#!/command/execlineb -P

fdmove -c 2 1
s6-setuidgid utmp
cd /run/utmps
fdmove 1 3
s6-ipcserver -1 -- /run/utmps/utmpd-socket
utmps-utmpd
```
## reference

- [s6-example](https://github.com/beldpro-ci/s6-entrypoint)
- [Docker and S6 – My New Favorite Process Supervisor](https://tutumcloud.wordpress.com/2014/12/02/docker-and-s6-my-new-favorite-process-supervisor/)
- [Building a skarnet.org s6 Init System](https://danmc.net/posts/s6-1/)
- [Quickstart and FAQ for s6-linux-init](http://skarnet.org/software/s6-linux-init/quickstart.html)
- [An overview of s6](https://skarnet.org/software/s6/overview.html)
- [s6 overlay](https://github.com/just-containers/s6-overlay)
- [S6 Made Easy, with the S6 Overlay](https://tutumcloud.wordpress.com/2015/05/20/s6-made-easy-with-the-s6-overlay/)
