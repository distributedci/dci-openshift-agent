#!/bin/bash
#
# Copyright (C) 2026 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Clean stale dci-pipeline containers that have been up for more than 24 hours

set -e

IMAGE="quay.io/distributedci/dci-pipeline:latest"
MAX_AGE_SECONDS=$((24 * 60 * 60))  # 24 hours
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Usage: $0 [--dry-run]"
            exit 1
            ;;
    esac
done

if $DRY_RUN; then
    echo "=== DRY RUN (no container will be killed) ==="
fi

# Get running container IDs with the target image
ids=$(podman ps --filter "ancestor=${IMAGE}" --format "{{.ID}}")

if [[ -z "$ids" ]]; then
    echo "No running containers found for image: ${IMAGE}"
    exit 0
fi

now=$(date +%s)
killed=0

for id in $ids; do
    # Get container start time (ISO 8601)
    started_at=$(podman inspect --format '{{.State.StartedAt}}' "$id")
    if [[ -z "$started_at" ]]; then
        echo "Warning: could not get StartedAt for container $id, skipping"
        continue
    fi

    # Parse to epoch (GNU date)
    started_epoch=$(date -d "$started_at" +%s 2>/dev/null || date -d "${started_at%% *}" +%s 2>/dev/null)
    if [[ -z "$started_epoch" ]]; then
        echo "Warning: could not parse StartedAt for container $id, skipping"
        continue
    fi

    age_seconds=$((now - started_epoch))
    if (( age_seconds >= MAX_AGE_SECONDS )); then
        name=$(podman inspect --format '{{.Name}}' "$id" | sed 's/^\///')
        if $DRY_RUN; then
            echo "[dry-run] Would kill container $id ($name) - up for $(( age_seconds / 3600 )) hours"
            ((killed++))
        else
            echo "Killing container $id ($name) - up for $(( age_seconds / 3600 )) hours"
            podman kill "$id" && ((killed++)) || echo "Failed to kill $id"
        fi
    fi
done

if $DRY_RUN; then
    echo "=== End of dry run ($killed container(s) would be killed) ==="
else
    echo "Done. Killed $killed container(s)."
fi
