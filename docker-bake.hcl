// Alpine version
variable "ALPINE_VERSION" {
  default = "latest"
}

target "args" {
  args = {
    ALPINE_VERSION = ALPINE_VERSION
  }
}

target "platforms" {
  platforms = [
    "linux/amd64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/arm64",
    "linux/386",
    "linux/ppc64le",
    "linux/s390x"
  ]
}

// Special target: https://github.com/crazy-max/ghaction-docker-meta#bake-definition
target "ghaction-docker-meta" {
  tags = ["alpine-s6:local"]
}

group "default" {
  targets = ["image-local"]
}

target "artifact" {
  inherits = ["args"]
  target = "artifacts"
  output = ["./dist"]
}

target "artifact-all" {
  inherits = ["platforms", "artifact"]
}

target "image" {
  inherits = ["args", "ghaction-docker-meta"]
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
}

target "image-all" {
  inherits = ["platforms", "image"]
}

target "image-dist" {
  inherits = ["image"]
  target = "dist"
}

target "image-dist-local" {
  inherits = ["image-dist"]
  output = ["type=docker"]
}

target "image-dist-all" {
  inherits = ["platforms", "image-dist"]
}