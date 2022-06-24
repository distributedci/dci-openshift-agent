# check-resource role

Role to wait for the correct deployment of a given resource. In case the check fails, a workaround is applied if defined on `dci_workarounds` list (if not, the task fails automatically) and the check is repeated again. This workflow is repeated multiple times, and if after these repetitions it is still failing, then the job fails.

It currently covers the following cases:

- MachineConfigPool - under `mcp_workaround.yml` play.
- SriovNetworkNodeState - under `sriov_workaround.yml` play.

The specific play must be called in order to do the check, then each of them call the `uncordon_workers.yml` play if the workaround is enabled.

## Parameters

Name                        | Required  | Default                | Description
--------------------------- |-----------|------------------------|-----------------------------------------------------------------------
num\_repetitions            | Yes       | 5                      | Maximum number of repetitions done in case the wait + workaround does not work.
retry\_count                | Yes       | 1                      | Number of retries performed in this role for a given call. It is incremented on each iteration. Maximum value that can reach is num\_repetitions.
check\_wait\_retries        | Yes       | Undefined              | Number of times in which the wait task is performed.
check\_wait\_delay          | Yes       | Undefined              | Time spent between wait tasks' iterations.
check\_wait\_delay          | Yes       | Undefined              | Time spent between wait tasks' iterations.
check\_reason               | No        | Undefined              | Reason for the check to be done.
