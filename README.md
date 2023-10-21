# Docker image for Rocket.chat (but bettter)

why is it better?
- use pre-built node images instead of [downloading it](https://github.com/RocketChat/Docker.Official.Image/blob/master/6.4/Dockerfile#L7)
- use Alpine linux instead of [Debian](https://github.com/RocketChat/Docker.Official.Image/blob/master/6.4/Dockerfile#L1)
- use static uid (1100) instead of using whatever is given [at runtime](https://github.com/RocketChat/Docker.Official.Image/blob/master/6.4/Dockerfile#L44-L45)
- removes ~200MB of docs from node_modules from meteor
- actually supports ARM64 instead of [still using RC 2.4.9](https://github.com/RocketChat/Rocket.Chat.Embedded.arm64/tree/develop/docker/rocketchat) (and without having to build it yourself)