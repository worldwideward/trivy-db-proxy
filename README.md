# Trivy DB proxy

This container image helps you to download the Trivy vulnerability dbs, and upload them to a private OCI registry.

## Usage

This is not a "long running" container. On task completion it will exit.

```bash
docker run --rm -ti \
        -e ORAS_REGISTRY_HOST=oci.example.com \
        -e ORAS_REGISTRY_USERNAME=ociuser \
        -e ORAS_REGISTRY_PASSWORD=xxxx \
        trivy-db-proxy
```
