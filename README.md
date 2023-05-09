## s6
docker image based on s6.

- [s6-example](https://github.com/beldpro-ci/s6-entrypoint)
- [Docker and S6 – My New Favorite Process Supervisor](https://tutumcloud.wordpress.com/2014/12/02/docker-and-s6-my-new-favorite-process-supervisor/)
- [Building a skarnet.org s6 Init System](https://danmc.net/posts/s6-1/)
- [Quickstart and FAQ for s6-linux-init](http://skarnet.org/software/s6-linux-init/quickstart.html)
- [An overview of s6](https://skarnet.org/software/s6/overview.html)
- [s6 overlay](https://github.com/just-containers/s6-overlay)
- [S6 Made Easy, with the S6 Overlay](https://tutumcloud.wordpress.com/2015/05/20/s6-made-easy-with-the-s6-overlay/)

## why S6-rc

- heavyweight daemons could consume cpu, mem, disk resources and increase the total booting time significantly.
- start/stop order matters, handle oneshot and longrun daemon interleave.
- daemons need dependency management.

## Traditional, sequential starters

## Monolithic Init

- Upstart: used ptrace on the processes it spawned in order to keep track of their forks.
- launched: uses XML for daemon configuration, has to link in a XML parsing library.
- systemd: up by an order of magnitude, doesn't even get readiness notification right.
