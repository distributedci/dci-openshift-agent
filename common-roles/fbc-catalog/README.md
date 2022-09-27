# fbc-catalog role

A Role to create File Base Catalogs (FBC) for Operator Lifecycle Manager (OLM). A list of operator bundles will be added to a catalog index using the FBC format.

In case the bundle image do not specify a channel via `"LABEL operators.operatorframework.io.bundle.channel.default.v1"` the default channel for the bundle will be set to "latest". The catalog image will be pushed to the registry according the values set for `fbc_target_registry`.

## Parameters

Name                        | Required  | Default                | Description                                        |
----------------------------|-----------| -----------------------|--------------------------------------------------- |
fbc_opm_args                | No        | ""                     | Arguments for opm command                          |
fbc_bundles                 | Yes       | undefined              | A list of bundles to be included in the catalog    |
fbc_target_registry         | Yes       | undefined              | Target <registry>/namespace/image:tag              |

## Example of usage

```yaml
- name: "Create an FBC catalog"
  include_role:
    name: fbc-catalog
  vars:
    fbc_target_registry: registry.dfwt5g.lab:4443/preflight/my_index:mytag
    fbc_bundles:
      - "quay.io/telcoci/simple-demo-operator-bundle@sha256:6cfbca9b14a51143cfc5d0d56494e7f26ad1cd3e662eedd2bcbebf207af59c86"
      - "quay.io/rh-nfv-int/testpmd-operator-bundle@sha256:5e28f883faacefa847104ebba1a1a22ee897b7576f0af6b8253c68b5c8f42815"
      - "quay.io/rh-nfv-int/testpmd-lb-operator-bundle@sha256:c26bd5bd75b3ad970597e0f628ede9d79c5417ea65de03e1a0e0752db8c3320c"
      - "quay.io/rh-nfv-int/trex-operator-bundle@sha256:12b0cfe22acd3ff4b2c2f1497e4068e06b44e0ca71d0519f131d5f4158e03e82"
      - "quay.io/rh-nfv-int/cnf-app-mac-operator-bundle@sha256:e5b8697136baa78bd1fa841c45adc3b539f8e853238ac8a33feeef67f70d3468"
      - "registry.dfwt5g.lab:4443/sriov-operator-bundle:latest"
    fbc_opm_args: "--skip-tls-verify=true"
```

## Note for disconnected catalogs.

If the catalog will be used in a disconnected environment, the references to the image bundles must be by its SHA.

