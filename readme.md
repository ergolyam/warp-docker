# warp-docker
This project builds a **small container image for Cloudflare WARP in local proxy mode**. It installs the official `cloudflare-warp` package and runs `supervisord` as the container process manager. Supervisor starts `warp-svc`, configures WARP for MASQUE + proxy mode, and exposes the local WARP proxy through `socat`.

## Build & run locally

- Build the runnable image:
    ```bash
    docker build -t warp-proxy -f dockerfile .
    ```

- Run it (persist WARP registration + expose the proxy):
    ```bash
    docker run -it --rm \
      -v warp-data:/var/lib/cloudflare-warp \
      -p 127.0.0.1:3080:3080 \
      warp-proxy
    ```
    - On first start, the container accepts the WARP ToS, creates a registration, and connects.
    - The named volume keeps the WARP registration between runs.
    - The exposed proxy listens on `127.0.0.1:3080` on the host.

- Use the proxy from the host:
    ```bash
    curl -x http://127.0.0.1:3080 https://www.cloudflare.com/cdn-cgi/trace
    ```
    - A successful WARP connection should show `warp=on` or `warp=plus` in the response.
    - Applications that support HTTP or SOCKS5 proxy settings can use the same host and port.

## Environment Variables

| Variable          | Default   | Description                                                   |
|-------------------|-----------|---------------------------------------------------------------|
| `WARP_PROXY_PORT` | `40000`   | Internal port used by the Cloudflare WARP local proxy.        |
| `LISTEN_HOST`     | `0.0.0.0` | Address `socat` binds to inside the container.                |
| `LISTEN_PORT`     | `3080`    | Container port exposed as the public proxy endpoint.          |

## Features

- **Local proxy appliance**: exposes Cloudflare WARP as a host-accessible proxy.
- **Persistent registration**: keeps WARP identity in the `warp-data` Docker volume.
- **Supervisor-managed startup**: `supervisord` owns `warp-svc`, one-time WARP bootstrap, and `socat`.
- **Fail-fast process supervision**: if `warp-svc`, `warp-bootstrap`, or `warp-socat` fails, Supervisor shuts down the remaining processes and the container exits with the failed service status.
- **Graceful shutdown**: stopping the container asks WARP to disconnect, terminates `warp-svc`, and stops `socat` as a process group.
- **Configurable listener**: internal and external proxy ports can be changed with environment variables.
