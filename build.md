# build the image

```sh
% docker build --build-arg ROOT_PWD=passowrd \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain  -t s6-ssh:0.1.0 -f s6.dockerfile .

% docker build --build-arg ROOT_PWD=passowrd \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain -t openrc-ssh:0.1.0 -f openrc.dockerfile .
```

## run image interactively
```sh
% docker run -ti --rm -h s6-ssh --name s6-ssh \
  --mount source=proj-vol,target=/home/ide/proj \
  --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
  s6-ssh:0.1.0 /bin/ash

% docker run -ti --rm -h s6-ssh --name s6-ssh s6-ssh:0.1.0 /bin/ash
% docker run -ti --rm -h openrc-ssh --name openrc-ssh openrc-ssh:0.1.0 /bin/ash

```

## run image in background
```sh
% docker run -d -p 22:22 -h s6-ssh --name s6-ssh \
  --mount source=proj-vol,target=/home/ide/proj \
  --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
  s6-ssh:0.1.0

% docker run --tty --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --mount source=proj-vol,target=/home/ide/proj \
  --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
  -h openrc-ssh --name openrc-ssh -d -p 5022:22 openrc-ssh:0.1.0
```

## login to the container
```sh
% rm ~/.ssh/known_hosts ~/.ssh/known_hosts.old
% ssh ide@localhost
% ssh root@localhost
% docker exec -u root -it s6-ssh ash
% docker exec -u ide -it s6-ssh ash

% ssh -p 5022 ide@localhost
% ssh -p 5022 root@localhost
% docker exec -u root -it openrc-ssh ash
```
