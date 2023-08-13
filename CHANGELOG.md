# Changelog

## 3.1.5.0-r0 (2023/08/13)

* s6-overlay 3.1.5.0 (#68)

## 3.1.4.2-r2 (2023/08/13)

* Upstream Alpine update

## 2.2.0.3-r22 (2023/08/13)

* Upstream Alpine update

## 3.1.4.2-r1 (2023/06/07)

* Alpine Linux 3.18 (#65)

## 2.2.0.3-r21 (2023/06/07)

* Alpine Linux 3.18 (#67)

## 3.1.4.2-r0 (2023/05/02)

* s6-overlay 3.1.4.2 (#61)

## 3.1.1.2-r3 (2023/03/27)

* Upstream Alpine update

## 2.2.0.3-r20 (2023/03/27)

* Upstream Alpine update

## 3.1.1.2-r2 (2022/12/28)

* Alpine Linux 3.17 (#54)

## 3.1.1.2-r1 (2022/07/24)

* Upstream Alpine update

## 2.2.0.3-r18 (2022/07/24)

* Upstream Alpine update

## 3.1.1.2-r0 (2022/07/11)

* s6-overlay 3.1.1.2 (#53)

## 3.1.1.0-r0 (2022/06/19)

* s6-overlay 3.1.1.0 (#52)

## 3.1.0.1-r2 (2022/05/31)

* Alpine Linux 3.16 (#51)

## 2.2.0.3-r17 (2022/05/28)

* Alpine Linux 3.16 (#50)

## 3.1.0.1-r1 (2022/05/15)

* Upstream Alpine update

## 2.2.0.3-r16 (2022/05/15)

* Upstream Alpine update

## 3.1.0.1-r0 (2022/03/26)

* s6-overlay 3.1.0.1 (#42)

## 3.0.0.2-r0 (2022/01/30)

* s6-overlay 3.0.0.2 (#39)

## 2.2.0.3-r15 (2021/12/03)

* Alpine Linux 3.15

## 2.2.0.3-r14 (2021/11/14)

* Upstream Alpine update

## 2.2.0.3-r13 (2021/08/29)

* Upstream Alpine update
* Update socklog and s6 libs (#32)

## 2.2.0.3-r12 (2021/07/03)

* Alpine Linux 3.14
* Drop Alpine Linux 3.11 support
* Drop s6 2.1 support

## 2.2.0.3-r11 / 2.1.0.2-r15 (2021/06/26)

* Upstream Alpine update
* Move to `docker/metadata-action`

## 2.2.0.3-r10 / 2.1.0.2-r14 (2021/04/14)

* Upstream Alpine update

## 2.2.0.3-r9 / 2.1.0.2-r13 (2021/04/01)

* Upstream Alpine update

## 2.2.0.3-r8 / 2.1.0.2-r12 (2021/03/18)

* Fix s6 tooling compil
* Enhance Dockerfile
* Wrong Alpine release used

## 2.2.0.3-r7 / 2.1.0.2-r11 (2021/03/03)

* Create dist image (#19)
* Add cache on ci (#20)

## 2.2.0.3-r6 / 2.1.0.2-r10 (2021/03/02)

* No need gosu (see https://github.com/crazy-max/gosu#from-dockerfile)

## 2.2.0.3-r5 / 2.1.0.2-r9 (2021/03/02)

* Add gosu

## 2.2.0.3-r4 / 2.1.0.2-r8 (2021/02/26)

* Upstream Alpine update

## 2.2.0.3-r3 / 2.1.0.2-r7 (2021/02/24)

* Upstream Alpine update

## 2.1.0.2-r6 (2021/02/20)

* s6-overlay 2.1 on a dedicated branch

## 2.2.0.3-r2 (2021/02/20)

* s6-overlay-preinit 1.0.5

## 2.2.0.3-r1 (2021/02/17)

* Upstream Alpine update

## 2.2.0.3-r0 (2021/02/16)

* s6-overlay 2.2.0.3 (#17)

## 2.2.0.1-r0 (2021/01/22)

* s6-overlay 2.2.0.1
* Alpine Linux 3.13
* Build skalibs from sources (2.10.0.1)
* Build execline from sources (2.7.0.1)
* Build s6 from sources (2.10.0.1)
* Build s6-dns from sources (2.3.5.0)
* Build s6-linux-utils from sources (2.5.1.4)
* Build s6-networking from sources (2.4.0.0)
* Build s6-portable-utils from sources (2.2.3.1)
* Build s6-rc from sources (0.5.2.1)
* Add justc-installer 1.0.1-2
* justc-envdir 1.0.1-1
* socklog 2.2.2
* socklog-overlay 3.1.1-1
* s6-overlay-preinit 1.0.4
* Switch to buildx bake

## 2.1.0.2-RC5 (2021/01/06)

* Handle alpine edge

## 2.1.0.2-RC4 (2020/12/17)

* Upstream Alpine update

## 2.1.0.2-RC3 (2020/12/11)

* Upstream Alpine update

## 2.1.0.2-RC2 (2020/11/25)

* Upstream Alpine update

## 2.1.0.2-RC1 (2020/10/24)

* s6-overlay 2.1.0.2

## 2.1.0.0-RC2 (2020/09/14)

* Add missing s6-overlay-preinit binary

## 2.1.0.0-RC1 (2020/09/13)

* s6-overlay 2.1.0.0

## 2.0.0.1-RC5 (2020/09/04)

* Add entrypoint (#8)

## 2.0.0.1-RC4 (2020/08/10)

* Keep socklog rules
* Review build stages

## 2.0.0.1-RC3 (2020/08/09)

* Add [socklog-overlay](https://github.com/just-containers/socklog-overlay)

## 2.0.0.1-RC2 (2020/08/09)

* Build `justc-envdir` from sources

## 2.0.0.1-RC1 (2020/08/07)

* Initial version based on [s6-overlay](https://github.com/just-containers/s6-overlay) 2.0.0.1
