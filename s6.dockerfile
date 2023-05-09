FROM alpine:edge
LABEL maintainer="ericwq057@qq.com"

# Arguement for passwords and ssh public key
#
ARG ROOT_PWD=s6_init_root
ARG USER_PWD=supervision
ARG SSH_PUB_KEY
ARG HOME=/home/ide

# S6 overlay version
#
ARG S6_OVERLAY_VERSION=3.1.5.0

# for s6, the default environment is blank, so the following ENV has no effect
#
#ENV TZ=Asia/Shanghai

# Create user/group 
# ide/develop
#
RUN addgroup develop && adduser -D -h $HOME -s /bin/ash -G develop ide

RUN apk add --no-cache --update openssh tzdata sudo tar xz htop utmps\
	&& sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
	&& sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config \
	&& echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel \
	&& ssh-keygen -A \
	&& adduser ide wheel \
	&& rm -rf /var/cache/apk/*

# extract s6-overlay
#
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/s6/
RUN tar xf /tmp/s6/s6-overlay-noarch.tar.xz -C /
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp/s6/
RUN tar xf /tmp/s6/s6-overlay-x86_64.tar.xz -C /
RUN rm -rf /tmp/s6

# enable root login, for debug dockerfile purpose.
# set root password
# set ide password
# set root public key login
RUN mkdir -p /root/.ssh \
	&& chmod 0700 /root/.ssh \
	&& echo "root:${ROOT_PWD}" | chpasswd \
	&& echo "ide:${USER_PWD}" | chpasswd \
	&& echo "$SSH_PUB_KEY" > /root/.ssh/authorized_keys

# prepare the s6-rc source definition directory
#
COPY ./etc/s6-rc.d/ /etc/s6-overlay/s6-rc.d/
RUN cd /etc/s6-overlay/s6-rc.d/user/contents.d/ \
	&& touch utmps-prepare wtmpd utmpd

# prepare s6 service directory
#
# COPY ./etc/s6/ /etc/services.d/
# RUN du -a /etc/services.d

# change the ssh hello message
#
COPY ./conf/motd 		/etc/motd

USER ide:develop
WORKDIR $HOME

# setup ssh for user ide
# setup public key login for normal user
#
RUN mkdir -p $HOME/.ssh \
	&& chmod 0700 $HOME/.ssh \
	&& echo "$SSH_PUB_KEY" > $HOME/.ssh/authorized_keys

# Set the environment for normal user: including TZ
# for s6, the default environment is blank, so we use the .profile instead.
#
COPY --chown=ide:develop ./conf/profile		$HOME/.profile

USER root

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

# start s6-overlay
#
ENTRYPOINT ["/init"]
