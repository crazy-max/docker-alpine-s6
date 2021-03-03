<p align="center">
  <a href="https://github.com/crazy-max/docker-alpine-s6/actions?workflow=build"><img src="https://img.shields.io/github/workflow/status/crazy-max/docker-alpine-s6/build?label=build&logo=github&style=flat-square" alt="Build Status"></a>
  <a href="https://hub.docker.com/r/crazymax/alpine-s6/"><img src="https://img.shields.io/docker/stars/crazymax/alpine-s6.svg?style=flat-square&logo=docker" alt="Docker Stars"></a>
  <a href="https://hub.docker.com/r/crazymax/alpine-s6/"><img src="https://img.shields.io/docker/pulls/crazymax/alpine-s6.svg?style=flat-square&logo=docker" alt="Docker Pulls"></a>
  <br /><a href="https://github.com/sponsors/crazy-max"><img src="https://img.shields.io/badge/sponsor-crazy--max-181717.svg?logo=github&style=flat-square" alt="Become a sponsor"></a>
  <a href="https://www.paypal.me/crazyws"><img src="https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square" alt="Donate Paypal"></a>
</p>

## About

Alpine Linux with [s6 overlay](https://github.com/just-containers/s6-overlay/).<br />
If you are interested, [check out](https://hub.docker.com/r/crazymax/) my other Docker images!

💡 Want to be notified of new releases? Check out 🔔 [Diun (Docker Image Update Notifier)](https://github.com/crazy-max/diun) project!

___

* [Features](#features)
* [Build locally](#build-locally)
* [Image](#image)
* [Dist image](#dist-image)
* [How can I help?](#how-can-i-help)
* [License](#license)

## Features

* Multi-platform image
* [socklog-overlay](https://github.com/just-containers/socklog-overlay) included
* [justc-installer](https://github.com/just-containers/justc-installer) included
* [gosu](https://github.com/tianon/gosu) included

## Build locally

```shell
git clone https://github.com/crazy-max/docker-alpine-s6.git
cd docker-alpine-s6

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all

# Build multi-platform dist image
docker buildx bake image-dist-all

# Build artifacts and output to ./dist
docker buildx bake artifact-all
```

## Image

| Registry                                                                                         | Image                           |
|--------------------------------------------------------------------------------------------------|---------------------------------|
| [Docker Hub](https://hub.docker.com/r/crazymax/alpine-s6/)                                            | `crazymax/alpine-s6`                 |
| [GitHub Container Registry](https://github.com/users/crazy-max/packages/container/package/alpine-s6)  | `ghcr.io/crazy-max/alpine-s6`        |

Following platforms for this image are available:

```
$ docker run --rm mplatform/mquery crazymax/alpine-s6:latest
Image: crazymax/alpine-s6:latest
 * Manifest List: Yes
 * Supported platforms:
   - linux/amd64
   - linux/arm/v6
   - linux/arm/v7
   - linux/arm64
   - linux/386
   - linux/ppc64le
   - linux/s390x
```

## Dist image

A distribution image is also available which only contains the required artifacts:

| Registry                                                                                         | Image                           |
|--------------------------------------------------------------------------------------------------|---------------------------------|
| [Docker Hub](https://hub.docker.com/r/crazymax/alpine-s6-dist/)                                            | `crazymax/alpine-s6-dist`                 |
| [GitHub Container Registry](https://github.com/users/crazy-max/packages/container/package/alpine-s6-dist)  | `ghcr.io/crazy-max/alpine-s6-dist`        |

## Supported tags

* `edge`, `edge-x.x.x.x`
* `latest-edge`, `3.13-edge`
* `latest`, `latest-x.x.x.x`, `3.13`, `3.13-x.x.x.x`
* `3.13-x.x.x.x`, `latest-x.x.x.x`
* `3.12-edge`
* `3.12`, `3.12-x.x.x.x`
* `3.12-x.x.x.x`
* `3.11-edge`
* `3.11`, `3.11-x.x.x.x`
* `3.11-x.x.x.x`

> `x.x.x.x` has to be replaced with one of the s6-overlay releases available (e.g. `2.1.0.0`).

## How can I help?

All kinds of contributions are welcome :raised_hands:! The most basic way to show your support is to star :star2:
the project, or to raise issues :speech_balloon: You can also support this project by
[**becoming a sponsor on GitHub**](https://github.com/sponsors/crazy-max) :clap: or by making a
[Paypal donation](https://www.paypal.me/crazyws) to ensure this journey continues indefinitely! :rocket:

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See `LICENSE` for more details.
