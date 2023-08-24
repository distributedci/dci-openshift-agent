# combine-auths role

A Role to combine multiple Podman credentials in JSON format passed as dictionaries. Input files are processed in order, in case of duplicated entries the last one processed will take precedence.

## Parameters

Name             | Required | Default        | Description
-----------------|----------| ---------------|-------------
mrc_auth_dics    | Yes      |                | A list of dictionaries containing authentication entries that will be merged

## Outputs

The `mrc_auth_file` variable points to the file can be used directly in images mirroring or inspection tools that support the JSON auths format. 

The `mrc_auth_data` variable contains the result of combining all the authentication files.

## Example of usage

```yaml
- name: "Combine registry auth secrets"
  include_role:
    name: merge-registry-creds
  vars:
    mrc_auth_files:
     - "<dictionary-1>"
     - "<dictionary-2>"
```
