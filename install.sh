#!/bin/bash

QUIET=0
FULL_RESOURCE_INSTALL=0
SKIP_RESOURCE_INSTALL=0
LINUX_PACKAGE_MANAGER="apt-get"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEARCH_VULNS_PATH="$SCRIPT_DIR/search_vulns.py"

install_linux_packages() {
    PACKAGES="git python3 python3-pip wget curl sqlite3 libsqlite3-dev libmariadb-dev jq"

    ${LINUX_PACKAGE_MANAGER} update

    ${LINUX_PACKAGE_MANAGER} -y install ${PACKAGES}

    pip3 install --no-cache-dir -r requirements.txt
    pip3 install --no-cache-dir mariadb
}

run_module_installs() {
    WORKING_DIR=$(pwd)
    find modules -type f -name 'search_vulns_*.py' | while read -r MODULE_FILE; do
        MODULE_SCRIPT_DIR=$(dirname "$MODULE_FILE")
        python3 - <<EOF
import os
import runpy
import sys

try:
    globals_dict = runpy.run_path("${MODULE_FILE}")
    os.chdir("${MODULE_SCRIPT_DIR}")
    if 'install' in globals_dict and callable(globals_dict['install']):
        print('[+] Installing module at ${MODULE_FILE}')
        globals_dict['install']()
except Exception as e:
    print(f"Error in ${MODULE_FILE}: {e}", file=sys.stderr)
EOF

        cd $WORKING_DIR
    done
}

create_local_databases() {
    if [ $FULL_RESOURCE_INSTALL != 0 ]; then
        "${SEARCH_VULNS_PATH}" --full-update
    else
        "${SEARCH_VULNS_PATH}" -u
    fi

    if [ $? != 0 ]; then
        echo "Could not create local databases."
        exit 1
    fi
}

# Run install steps
install_linux_packages

git submodule init
git submodule update

run_module_installs

if [ $SKIP_RESOURCE_INSTALL == 0 ]; then
    create_local_databases
else
    echo "Skipping install of vulnerability and software database."
fi

ln -sf "$(pwd -P)/search_vulns.py" /usr/local/bin/search_vulns
