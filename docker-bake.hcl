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
  platforms = ALPINE_VERSION == "3.22" || ALPINE_VERSION == "3.21" || ALPINE_VERSION == "3.20" || ALPINE_VERSION == "latest" || ALPINE_VERSION == "edge" ? [
    "linux/386",
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/ppc64le",
    "linux/riscv64",
    "linux/s390x"
  ] : [
    "linux/386",
    "linux/amd64",
    "linux/arm64",
    "linux/arm/v6",
    "linux/arm/v7",
    "linux/ppc64le",
    "linux/s390x"
  ]
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
  tags = ["alpine-s6:local"]
}

group "default" {
  targets = ["image-local"]
}

target "artifact" {
  inherits = ["args"]
  target = "artifact"
  output = ["./dist"]
}

target "artifact-all" {
  inherits = ["platforms", "artifact"]
}

target "image" {
  inherits = ["args", "docker-metadata-action"]
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
