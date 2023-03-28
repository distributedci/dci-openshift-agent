#!/bin/bash

# A shell script to remove dangling containers for the artifacts web server
# The Remore CI is used to confirm the Job status
# Params: The path to a valid remote CI
# shellcheck source=/dev/null

function help(){
    echo "$(basename "$0") <remote_ci_path>"
    echo "Absolute path to remote CI is missing"
}

if [[ $# != 1 ]]; then
    echo "Error: Missing remote CI" >&2
    help
    exit 1
fi

# Source the remote CI file
remote_ci="${1}"
if [[ ! -f $remote_ci ]]; then
    echo "Remote CI: ${remote_ci} does not exist, skipping" >&2
    exit 1
fi
source "${remote_ci}"

# Get the container names
containers=$(podman ps -a --sort created --filter 'name=\w{8}(-\w{4}){3}-\w{8}' --format "{{.Names}}");

# Loop over the containers and check their job status
while IFS=, read -r name
do
  # Check if the job is in a failure state
  fail_states=( failure error killed )
  job_status=$(dcictl --format json job-show "${name}" | jq -er .job.jobstates[-1].status)
  if [[ " ${fail_states[*]} " =~ ${job_status} ]]; then
    port=$(podman inspect "${name}" | jq -r '.[].NetworkSettings.Ports."8080/tcp"[0].HostPort')
    sudo firewallcmd --remove-port="${port}"/tcp
    podman rm -f "${name}"
  fi
done <<< "${containers}"