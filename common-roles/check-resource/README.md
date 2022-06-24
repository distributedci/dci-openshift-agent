# check-resource role

Role to wait for the correct deployment of a given resource. In case the check fails, a workaround is applied if defined on `dci_workarounds` list (if not, the task fails automatically) and the check is repeated again. This workflow is repeated multiple times, and if after these repetitions it is still failing, then the job fails.

It currently covers the following cases:

- MachineConfigPool
- SriovNetworkNodeState

## Parameters

Name                        | Required  | Default                | Description
--------------------------- |-----------|------------------------|-----------------------------------------------------------------------
num\_repetitions            | Yes       | 5                      | Number of repetitions done in case the wait + workaround does not work.
resource\_to\_check         | Yes       | MachineConfigPool      | Name of the resource to check. Possible values: "MachineConfigPool", or "SriovNetworkNodeState".
retry\_count                | Yes       | 0                      | Number of retries performed in this role for a given call.
check\_wait\_retries        | Yes       | Undefined              | Number of times in which the wait task is performed
check\_wait\_delay          | Yes       | Undefined              | Time spent between wait tasks' iterations
check\_wait\_delay          | Yes       | Undefined              | Time spent between wait tasks' iterations
check\_reason               | Yes       | Undefined              | Reason for the check to be done
