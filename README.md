# Trivy DB proxy

This container image helps you to download the Trivy vulnerability dbs, and upload them to a private OCI registry.

## Usage

This is not a "long running" container. On task completion it will exit.

```bash
# Run with plain-text credentials
docker run --rm -ti \
        -e ORAS_REGISTRY_HOST=oci.example.com \
        -e ORAS_REGISTRY_USERNAME=ociuser \
        -e ORAS_REGISTRY_PASSWORD=xxxx \
        -e DEBUG=False \
        trivy-db-proxy
```

## Kubernetes cronjob and workload identities

You can run this container as a cronjob, and if you are using Azure RBAC, you can enable "workload identities"

Omit the variable `ORAS_REGISTRY_PASSWORD` since it will be retrieved dynamically.

In this case, the `ORAS_REGISTRY_USERNAME` must be `00000000-0000-0000-0000-000000000000`

```bash
# cronjob environment configuration (see also k8s/cronjob-az-wi.yaml)
env:
- name: ORAS_REGISTRY_HOST
  value: "myregistry.azurecr.io"
- name: ORAS_REGISTRY_USERNAME
  value: "00000000-0000-0000-0000-000000000000"
- name: DEBUG
  value: "False"
- name: AZURE_WORKLOAD_IDENTITIES
  value: "True"
```
