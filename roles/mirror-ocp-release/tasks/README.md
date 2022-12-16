# Mirror OCP release role

This role will mirror a given OpenShift release version to a given cache directory.  The directory is supposed to be served behind an HTTP server (e.g. apache) so the cluster to be installed can reach it.

If enabled, the role requires an container registry to mirror the OCP container images.

## Variables

| Variable                    | Default       | Required    | Description                                                                                                                  |
| ----------------------------| ------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------- |
| mor_version                  | undefined     | Yes         | An OpenShift version number e.g. 4.10.45                                                                                     |
| mor_cache_dir                | /var/lib/dci-openshift-agent/releases | No          | Base directory that will hold the OCP version binaries and OS images                                 |
| mor_release_url              | sno           | No          | The base URL where the release artifacts are stored                                                                          |
| mor_force                    | false         | No          | If passed as true, the role will re-download all the OCP release resources                                                   |
| mor_mirror_artifacts         | true          | No          |  Download tarball artifacts from the OCP mirror                                                                           |
| mor_unpack_artifacts         | true          | No          | Unpack all downloaded tarball artifacts                                                                                   |
| mor_artifacts                | [opm-linux-{{ version }}.tar.gz]| No          | List of all artifacts to download from the OCP mirror *besides installer*                               |
| mor_mirror_disk_images       | true          | No          | Download all disk images depending on which install type                                                                     |
| mor_mirror_container_images  | true          | No          | Mirror all container images from upstream container registries to the provided registry                                      |
| mor_auths_file               | undefined     | No          | Path to the file containing all authentications needed for container registries e.g.  quay.io                                |
| mor_write_custom_config      | true          | No          | Writes the OCP configuration files and sets the custom URL facts                                                             |
| mor_webserver_url            | undefined     | No          | Name of the spoke cluster                                                                                                    |
| mor_registry_url             | undefined     | No*         | Required if `mor_mirror_container_images` is True. Registry where to mirror the upstream container images to                    |
| mor_install_type             | ipi           | No          | What method will be used to install this cluster, this will define what type of disk images to mirror                        |

## Usage example

See below for some examples of how to use the mirror-ocp-release role

```yaml
- name: Mirror release
  include_role:
    name: mirror-ocp-release
  vars:
    mor_version: "4.13.0-ec.1"
    mor_release_url: "https://mirror.openshift.com/pub/openshift-v4/clients/ocp-dev-preview/4.13.0-ec.1/"
    mor_cache_dir: "/opt/cache"
    mor_webserver_url: "https://<mywebserver>"
    mor_registry_url: "docker://<my-registry>/ocp4/openshift4"
    mor_auths_file: "/var/<pull_secret>"
    mor_force: true
    mor_install_type: "ipi"
    mor_mirror_artifacts: true
    mor_unpack_artifacts: true
    mor_mirror_disk_images: true
    mor_mirror_container_images: true
    mor_write_custom_config: true
```
