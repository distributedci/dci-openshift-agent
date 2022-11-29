# catalog-source role

A Role to deploy an OLM-based CatalogSource

## Parameters
Name             | Required | Default        | Description
-----------------|----------| ---------------|-------------
cs_name          | Yes      |                | Name of the CatalogSource to create
cs_image         | Yes      |                | Catalog Image URL
cs_namespace     | No       | openshift-marketplace  | Namespace where the CatalogSource will be defined
cs_publisher     | No       | Red Hat             | CatalogSource publisher
cs_type          | No       | grpc      | CatalogSource type
