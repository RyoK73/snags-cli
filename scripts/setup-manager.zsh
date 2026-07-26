#!/usr/bin/env zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
MANAGER_SCRIPT="${SCRIPT_DIR}/gists-tips-manager.zsh"
ZSHRC="${HOME}/.zshrc"
SOURCE_LINE="source \"${MANAGER_SCRIPT}\""

if [[ ! -f "${ZSHRC}" ]]; then
  echo ".zshrc not found"
  if gum confirm "Create .zshrc?"; then
    touch $HOME/.zshrc
    echo "Created .zshrc at ${HOME}"
  else
    echo "Cancelled"
    exit 1
  fi
fi

if grep -qF "${MANAGER_SCRIPT}" "${ZSHRC}"; then
  echo "Already set up: ${ZSHRC} already sources ${MANAGER_SCRIPT}"
else
  {
    echo ""
    echo "# gists-tips-manager"
    echo "${SOURCE_LINE}"
  } >>"${ZSHRC}"
  echo "Added: ${SOURCE_LINE} to ${ZSHRC}"
fi
