# https://github.com/gliderlabs/docker-alpine/issues/437
#
# FROM alpine
#
# EXPOSE 22
#
# RUN apk update \
#     && apk add --no-cache openssh-server openrc \
#     && mkdir -p /run/openrc \
#     && touch /run/openrc/softlevel \
#     && mkdir /repos /repos-backup \
#     && sed -ie "s/#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config \
#     && sed -ie "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config \
#     && echo "0 5 * * * cd /repos ;for i in $(ls); do echo -n '$i : ' ;git -C $i pull 2>/dev/null ;done" > /etc/crontabs/root \
#     && echo "30 5 * * * rsync -qr /repos/* /repos-backup" > /etc/crontabs/root
#
# ENTRYPOINT ["sh","-c", "rc-status; rc-service sshd start; crond -f"]

# https://github.com/neeravkumar/dockerfiles/blob/master/alpine-openrc/Dockerfile
#
# FROM alpine:edge
#
# # Install openrc
# RUN apk update && apk add openrc utmps &&\
# # Tell openrc its running inside a container, till now that has meant LXC
#     sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf &&\
# # Tell openrc loopback and net are already there, since docker handles the networking
#     echo 'rc_provide="loopback net"' >> /etc/rc.conf &&\
# # no need for loggers
#     sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf &&\
# # can't get ttys unless you run the container in privileged mode
#     sed -i '/tty/d' /etc/inittab &&\
# # can't set hostname since docker sets it
#     sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname &&\
# # can't mount tmpfs since not privileged
#     sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh &&\
# # can't do cgroups
#     sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh &&\
# # clean apk cache
#     rm -rf /var/cache/apk/*
# CMD ["/sbin/init"]

# https://github.com/robertdebock/docker-alpine-openrc/blob/master/dockerfiles
#
FROM alpine:edge

LABEL maintainer="Robert de Bock <robert@meinit.nl>"
LABEL build_date="2022-05-18"

ENV container=docker

# Enable init.
RUN apk add --update --no-cache openrc && \
    sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab && \
    sed -i \
      -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
      -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
      -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
      -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
      -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
      /etc/rc.conf && \
    rm -f /etc/init.d/hwdrivers \
      /etc/init.d/hwclock \
      /etc/init.d/hwdrivers \
      /etc/init.d/modules \
      /etc/init.d/modules-load \
      /etc/init.d/modloop && \
    sed -i 's/cgroup_add_service /# cgroup_add_service /g' /lib/rc/sh/openrc-run.sh && \
    sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh

VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
