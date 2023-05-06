# build the image

```sh
% docker build --build-arg ROOT_PWD=passowrd \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain  -t s6-ssh:0.1.0 -f s6.dockerfile .
```

## dryrun the image

```sh

% docker run -d -p 22:22 -h s6-ssh --name s6-ssh \
  --mount source=proj-vol,target=/home/ide/proj \
  --mount type=bind,source=/Users/qiwang/dev,target=/home/ide/develop \
  s6-ssh:0.1.0
```

## login to the container
```sh
% rm ~/.ssh/known_hosts ~/.ssh/known_hosts.old
% ssh ide@localhost
% ssh root@localhost
% docker exec -u root -it s6-ssh ash
% docker exec -u ide -it s6-ssh ash
```
