# Remove nodes

This playbook helps to remove a list of workers in a baremetal deployment

```ShellSession
export KUBECONFIG=/path/to/kubeconfig

ansible-playbook remove_nodes.yml \
  -e '{ "nodes_to_remove":["worker-0", "worker-1", ..]}'
```
