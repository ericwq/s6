# build the image

```sh
% docker build --build-arg ROOT_PWD=passowrd \
	--build-arg USER_PWD=password \
	--build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
	--progress plain  -t s6-ssh:0.1.0 -f s6.dockerfile .
```

## dryrun the image

```sh
% docker run -ti --rm -u ide -p 22:22 s6-ssh:0.1.0
```
