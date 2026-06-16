#!/bin/bash

# A shell script that deletes repositories from a Quay image registry if the OCP release directory is not present
# in the cache_directory

bearer_code="${1}"
registry_url="${2}"
cache_dir="${3:-/opt/cache/}"
workdir=$(mktemp -d)
results="${workdir}/results"
remove_tags="${workdir}/remove_tags"
trap 'rm -rf "${workdir}"' EXIT
max_minor=25

declare -A OCP_MINOR_MIN=(
  [4]=7
  [5]=0
)

function help(){
    echo "Usage: $(basename "$0") <bearer_code> <registry_url> [cache_dir]"
    echo ""
    echo "Parameters:"
    echo "  bearer_code  - Bearer token for registry authentication (required)"
    echo "  registry_url - Registry URL (required)"
    echo "  cache_dir    - Cache directory path (default: /opt/cache/)"
    echo ""
    echo "Note: Write permissions are required for the registry"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") your_bearer_token registry.example.com:5000"
    echo "  $(basename "$0") your_bearer_token registry.example.com:5000 /custom/cache/"
    exit 1
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Error: Invalid number of arguments" >&2
    help
fi

# Get nightly repositories for each OCP version in the range
for major in 4 5; do
    for minor in $(seq "${OCP_MINOR_MIN[${major}]}" "${max_minor}"); do
        namespace="ocp-${major}.${minor}"
        api_results=$(curl -q -s -H "Authorization: Bearer ${bearer_code}" "https://${registry_url}/api/v1/repository?namespace=${namespace}&public=true&private=true")
        echo "${api_results}" | jq -r --arg ns "${namespace}" '.repositories[]? | "\($ns)|\(.name)"' >> "${results}"
    done
done

# Get cached OCP releases
ocp_vers=$(find "${cache_dir}" -type d \( -iname '4.*' -o -iname '5.*' \) -printf '%f|')
ocp_vers="(${ocp_vers%|})"

# Filter OCP releases in the registry that are not in the cache dir
if [[ -n "${ocp_vers}" && "${ocp_vers}" != "()" ]]; then
    grep -vP "${ocp_vers}" "${results}" > "${remove_tags}"
else
    cp "${results}" "${remove_tags}"
fi

# Removing unused nightly repositories
while IFS='|' read -r namespace repo; do
    [[ -z "${namespace}" || -z "${repo}" ]] && continue
    curl -s -X DELETE -H "Authorization: Bearer ${bearer_code}" "https://${registry_url}/api/v1/repository/${namespace}/${repo}"
done < "${remove_tags}"
