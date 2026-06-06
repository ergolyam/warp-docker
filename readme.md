# warp-docker

Lightweight container image for [Cloudflare WARP](https://developers.cloudflare.com/warp-client).

## Initial Setup

### Build

```bash
docker build -t warp-proxy .
```

## Run

The container starts `warp-svc`, registers WARP when no existing registration is found, enables local proxy mode, and exposes the proxy port through `socat`.

- With persistent WARP registration:
    ```bash
    docker run --rm -it \
      -p 3080:3080 \
      -v warp-data:/var/lib/cloudflare-warp \
      warp-proxy
    ```

- With custom proxy port:
    ```bash
    docker run --rm -it \
      -p 1080:1080 \
      -e LISTEN_PORT=1080 \
      -v warp-data:/var/lib/cloudflare-warp \
      warp-proxy
    ```

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `LISTEN_HOST` | `0.0.0.0` | Proxy listen address exposed by `socat` |
| `LISTEN_PORT` | `3080` | Proxy listen port exposed by `socat` |
