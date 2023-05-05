FROM alpine:edge
LABEL maintainer="ericwq057@qq.com"

# Arguement for passwords and ssh public key
#
ARG ROOT_PWD=s6_init_root
ARG USER_PWD=supervision
ARG SSH_PUB_KEY
ARG HOME=/home/ide

# Create user/group 
# ide/develop
#
RUN addgroup develop && adduser -D -h $HOME -s /bin/ash -G develop ide

RUN apk add --no-cache --update s6 bash openssh tzdata sudo \
	&& sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
	&& sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
	&& echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel \
	&& ssh-keygen -A \
	&& adduser ide wheel \
	&& rm -rf /var/cache/apk/*

# enable root login, for debug dockerfile purpose.
# set root password
# set ide password
# set root public key login
RUN mkdir -p /root/.ssh \
	&& chmod 0700 /root/.ssh \
	&& echo "root:${ROOT_PWD}" | chpasswd \
	&& echo "ide:${USER_PWD}" | chpasswd \
	&& echo "$SSH_PUB_KEY" > /root/.ssh/authorized_keys

# prepare the scan directory
ADD ./etc /etc
RUN mkdir -p /etc/s6/sshd \
	&& ln -s /etc/init.d/sshd /etc/s6/sshd/run \
	&& ln -s /bin/true /etc/s6/sshd/finish

# change the ssh hello message
#
COPY ./conf/motd 		/etc/motd

RUN ls -al /etc/s6/
RUN ls -al /etc/s6/sshd
RUN ls -al /etc/s6/.s6-svscan

USER ide:develop
WORKDIR $HOME

# setup ssh for user ide
# setup ide public key login
#
RUN mkdir -p $HOME/.ssh \
	&& chmod 0700 $HOME/.ssh \
	&& echo "$SSH_PUB_KEY" > $HOME/.ssh/authorized_keys
USER root

EXPOSE 22

# Adding `s6-svscan` as our entrypoint guarantees that
# we'll have it running as our PID-1 processes.
#
# /etc/s6 indicates the "scan directory", that is,
# where our services live.
ENTRYPOINT [ "/bin/s6-svscan", "/etc/s6" ]
