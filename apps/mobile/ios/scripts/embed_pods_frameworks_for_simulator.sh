#!/bin/bash
set -euo pipefail

frameworks_list="${PODS_ROOT}/Target Support Files/Pods-Runner/Pods-Runner-frameworks-${CONFIGURATION}-input-files.xcfilelist"
destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

mkdir -p "${destination}"

while IFS= read -r input || [[ -n "${input}" ]]; do
  [[ "${input}" == *.framework ]] || continue

  source_path="$(eval "printf '%s' \"${input}\"")"
  if [[ ! -d "${source_path}" ]]; then
    echo "warning: missing CocoaPods framework: ${source_path}"
    continue
  fi

  rsync --delete -av --links \
    --filter "P .*.??????" \
    --filter "- CVS/" \
    --filter "- .svn/" \
    --filter "- .git/" \
    --filter "- .hg/" \
    --filter "- Headers" \
    --filter "- PrivateHeaders" \
    --filter "- Modules" \
    "${source_path}" \
    "${destination}"
done < "${frameworks_list}"
