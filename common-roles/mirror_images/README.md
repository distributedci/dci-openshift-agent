# Mirror Images

Mirrors images from a source registry into a target registry.

When there's a problem with the source registry a target registry is checked to see if an image is already in place as a safety net. This is not a guarantee that the image in the target registry is the same as the source, but it at least provides an image that was copied previously.

This safety net mechanism is useful when there are issues with the source registry. For example, a threshold has been met or there are network issues with the registry.

## Role Variables

Name              | Required | Default | Description
----------------- | ---------| --------|-------------
mi_images         | Yes      |         | A list of images using a Fully Qualified Artifact Reference, e.g. example.com/namespace/web:v1.0
mi_local_registry | Yes      |         | The target registry where the images will be mirrored, e.g. registry.example.com
mi_authfile       | No       |         | The path to the authentication file for the registries
mi_src_authfile   | No       |         | The path to the authentication file for the source registries
mi_dest_authfile  | No       |         | The path to the authentication file for the target registries

## Dependencies

The following applications must be already present in the system.

- [skopeo](https://github.com/containers/skopeo/blob/main/install.md).

## Outputs

This role does not provide an output

## Example Playbook

As a role:

```yaml
- hosts: localhost
  roles:
     - role: mirror_image
       vars:
         mi_images:
           - example.com/my-org/my-image:latest
           - quay.io/org/another-image:v1.2.3
         mi_src_authfile: /path/to/my/source-auth.json
         mi_dest_authfile: /path/to/my/target-auth.json
         mi_local_registry: registry.example.com:4443
         
```

As a task:

```yaml
- name: Mirror Images
  include_role:
    name: mirror_images
  vars:
    mi_images:
      - example.com/my-org/my-image:latest
      - quay.io/org/another-image:v1.2.3
    mi_authfile: /path/to/my/auth.json
    mi_local_registry: registry.example.com
```

## License

Apache License, Version 2.0
