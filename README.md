# Docker Alpine SSH Client

[![Docker Image CI](https://github.com/chenwei791129/docker-alpine-ssh-client/actions/workflows/docker-image.yml/badge.svg)](https://github.com/chenwei791129/docker-alpine-ssh-client/actions/workflows/docker-image.yml)

A lightweight Docker image based on Alpine Linux with OpenSSH client pre-installed, specifically designed for application deployment scenarios.

## Features

- 🐧 Based on Alpine Linux for minimal image size (~14MB)
- 🔑 OpenSSH client pre-installed with `StrictHostKeyChecking` disabled
- 🚀 Ready for CI/CD deployments

## Image Variants

| Tags | Dockerfile | Contents |
|------|------------|----------|
| `alpine`, `alpine-<version>`, `latest` | `Dockerfile` | `openssh-client`, `rsync`, `sshpass` |
| `alpine-fat`, `alpine-<version>-fat`, `fat` | `Dockerfile.fat` | Everything above, plus `bash` and `jq` for deployment scripts |

Prefer the slim image; use the `-fat` variant only when your job needs the extra tools and cannot install them at runtime.

## CI/CD Examples

### GitLab CI
```yaml
deploy:
  image: ghcr.io/chenwei791129/alpine-ssh-client:alpine
  before_script:
    - eval $(ssh-agent -s)
    - echo "${SSH_PRIVATE_KEY}" | ssh-add -
  script:
    - scp -r ./nginx.conf user@server:/etc/nginx/
    - ssh user@server "nginx -t && nginx -s reload"
```

## Building from Source

```bash
docker buildx build --build-arg BASE_TAG=3.22.1 --platform linux/amd64 -t local/alpine-ssh-client .

# fat variant
docker buildx build --build-arg BASE_TAG=3.22.1 --platform linux/amd64 -f Dockerfile.fat -t local/alpine-ssh-client:fat .
```

## License

MIT License - see [LICENSE](LICENSE) file for details.
