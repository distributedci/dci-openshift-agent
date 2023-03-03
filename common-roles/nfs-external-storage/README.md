# OLM-operator role

Role to NFS external storage provisioner. A storage class named managed-nfs-storage is created and set as default if no other default Storage Class is defined.

## Parameters

Name                        | Required  | Default                | Description
--------------------------- |-----------|------------------------|--------------------------------------
nes_nfs_server              | Yes       | undefined              | NFS server's FQDN or IP Address
nes_nfs_path                | Yes       | undefined              | NFS export path
nes_namespace               | No        | openshift-nfs-storage  | Deployment namespace
nes_provisioner_image       | No        | k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2 | Provisioner image

### Requirements

* A reachable NFS server
* A writable exported path

## Example of usage

```yaml
- name: "deploy-operators : Install OCS Operator"
  include_role:
    name: nfs-external-storage
  vars:
    nes_nfs_server: "192.168.16.11"
    nes_nfs_path: "/data/nfshare/clusterX"
```

### Creating a persistent volume claim
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
```

### Creating a pod binding to the PVC
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: gcr.io/google_containers/busybox:1.24
    command:
      - "/bin/sh"
    args:
      - "-c"
      - "touch /mnt/SUCCESS && exit 0 || exit 1"
    volumeMounts:
      - name: nfs-pvc
        mountPath: "/mnt"
  restartPolicy: "Never"
  volumes:
    - name: nfs-pvc
      persistentVolumeClaim:
        claimName: test-claim
```
## License
Apache License, Version 2.0