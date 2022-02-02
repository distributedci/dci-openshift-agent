# Development

## Table of Contents

- [Local dev environment](#local-dev-environment)
- [Libvirt environment](#libvirt-environment)
- [Testing a change](#testing-a-change)
  - [Advanced](#advanced)
    - [Dependencies](#dependencies)
    - [Prefix](#prefix)
    - [Hints](#hints)
- [Continuous integration](#continuous-integration)
- [Launching the agent without DCI calls](#launching-the-agent-without-dci-calls)

## Local dev environment

For dev purposes, it is important to be able to run and test the code directly
on your dev environment without using the package manager.

In order to run the agent without using the RPM package, you need to move the
three configuration files (`settings.yml`, `dcirc.sh` and `hosts`) in the
directory of the git repo.

Then, you need to modify dev-ansible.cfg two variables: `inventory` and
`roles_path` (baremetal_deploy_repo).

Also, in order to install package with the ansible playbook, you need to add
rights to `dci-openshift-agent` user:

```console
# cp dci-openshift-agent.sudo /etc/sudoers.d/dci-openshift-agent
```

Finally, you can run the script:

```console
## Option -d for dev mode
## Overrides variables with group_vars/dev
$ ./dci-openshift-agent-ctl -s -c settings.yml -d -- -e @group_vars/dev
```

## Libvirt environment

Please refer to the [full libvirt documentation](ocp_on_libvirt.md) to setup
your own local libvirt environment

## Testing a change

If you want to test a change from a Gerrit review or from a GitHub PR,
use the `dci-check-change` command. Example:

```console
dci-check-change 21136
```

to check https://softwarefactory-project.io/r/#/c/21136/ or from a
GitHub PR:

```console
dci-check-change https://github.com/myorg/lab-config/pull/42
```

Regarding Github, you will need a token to access private repositories
stored in `~/.github_token`.

`dci-check-change` will launch a DCI job to perform an OCP
installation using `dci-openshift-agent-ctl` and then launch another
DCI job to run an OCP workload using `dci-openshift-app-agent-ctl` if
`dci-openshift-app-agent-ctl` is present on the system.

You can use `dci-queue` from the `dci-pipeline` package to manage a
queue of changes. To enable it, add the name of the queue into
`/etc/dci-openshift-agent/config`:

```console
DCI_QUEUE=<queue name>
```

If you have multiple prefixes, you can also enable it in
`/etc/dci-openshift-agent/config`:

```console
USE_PREFIX=1
```

This way, the resource from `dci-queue` is passed as the prefix for
`dci-openshift-app-agent-ctl`.

### Advanced

#### Dependencies

If the change you want to test has a `Depends-On:` or `Build-Depends:`
field, `dci-check-change` will install the corresponding change and
make sure all the changes are tested together.

#### Prefix

If you want to pass a prefix to the `dci-openshift-agent` use the `-p`
option and if you want to pass a prefix to the
`dci-openshift-app-agent` use the `-p2` option. For example:

```console
dci-check-change https://github.com/myorg/lab-config/pull/42 -p prefix -p2 app-prefix
```

#### Hints

You can also specify a `Test-Hints:` field in the description of your
change. This will direct `dci-check-change` to test in a specific way:

- `Test-Hints: sno` validate the change in SNO mode.
- `Test-Hints: libvirt` validate in libvirt mode (3 masters).
- `Test-Hints: no-check` do not run a check (useful in CI mode).

`Test-Args-Hints:` can also be used to specify extra parameters to
pass to `dci-check-change`.

`Test-App-Hints:` can also be used to change the default app to be
used (`basic_example`). If `none` is specified in `Test-App-Hints:`,
the configuration is taken from the system.

Hints need to be activated in the `SUPPORTED_HINTS` variable in
`/etc/dci-openshift-agent/config` like this:

```console
SUPPORTED_HINTS="sno|libvirt|no-check|args|app"
```

## Continuous integration

You can use
`/var/lib/dci-openshift-agent/samples/ocp_on_libvirt/ci.sh` to setup
your own CI system to validate changes.

To do so, you need to set the `GERRIT_SSH_ID` variable to set the ssh
key file to use to read the stream of Gerrit events from
`softwarefactory-project.io`. And `GERRIT_USER` to the Gerrit user to
use.

The `ci.sh` script will then monitor the Gerrit events for new changes
to test with `dci-check-change` and to report results to Gerrit.

For the CI to vote in Gerrit and comment in GitHub, you need to set
the `DO_VOTE` variable in `/etc/dci-openshift-agent/config` like this:

```console
DO_VOTE=1
```

## Launching the agent without DCI calls

The `dci` tag can be used to skip all DCI calls. You will need to
provide fake `job_id` and `job_info` variables in a `myvars.yml` file
like this:

```YAML
job_id: fake-id
job_info:
  job:
    components:
    - name: 1.0.0
      type: my-component
```

and then call the agent like this:

```console
# su - dci-openshift-agent
$ dci-openshift-agent-ctl -s -- --skip-tags dci -e @myvars.yml
```
