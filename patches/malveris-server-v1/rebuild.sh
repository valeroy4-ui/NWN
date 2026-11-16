#!/usr/bin/env bash
set -euo pipefail
mv_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ "$#" -ne 1 ]; then
    echo 'Usage: bash rebuild.sh /absolute/path/to/nwnsc' >&2
    exit 2
fi
mv_compiler="$(realpath -- "$1")"
mkdir -p "$mv_root/rebuilt"
cd "$mv_root/source"
"$mv_compiler" -i "$mv_root/source;$mv_root/vendor" -b "$mv_root/rebuilt" \
    p_malv_heart.nss malv_spawn.nss malv_round.nss malv_death.nss malv_jump.nss _mod_chat.nss
echo "Rebuilt scripts: $mv_root/rebuilt. Deployment files are unchanged."
