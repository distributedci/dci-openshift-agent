# combine-auths role

A Role to combine multiple Podman credential files in JSON format. Input files are processed in order, in case of duplicated entries the last one processed will take precedence.

## Parameters

Name             | Required | Default        | Description
-----------------|----------| ---------------|-------------
mrc_auth_files    | Yes      |                | A list of auth files to be merged.

## Outputs

The role copies the combined auth files into a temporary file with `auth_` prefix.

The `mrc_auth_file` variable points to the file can be used directly in images mirroring or inspection tools that support the JSON auths format. 

The `mrc_auth_data` variable contains the result of combining all the authentication files.

The role also sets a variable with the path to the file: `auths_file.path` that can be used to access the combined auths file after in post tasks.

## Example of usage

```yaml
- name: "Combine auth files"
  include_role:
    name: merge-registry-creds
  vars:
    mrc_auth_files:
     - "/path/auth1.json"
     - "/path/auth2.json"
```
