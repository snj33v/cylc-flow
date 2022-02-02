#!/usr/bin/env bash
# THIS FILE IS PART OF THE CYLC WORKFLOW ENGINE.
# Copyright (C) NIWA & British Crown (Met Office) & Contributors.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------------------
# Test remote host job log NN link correctness.
export REQUIRE_PLATFORM='loc:remote'
. "$(dirname "$0")/test_header"
set_test_number 2
install_workflow "${TEST_NAME_BASE}" "${TEST_NAME_BASE}"

run_ok "${TEST_NAME_BASE}-validate" cylc validate "${WORKFLOW_NAME}"
mkdir -p "${WORKFLOW_RUN_DIR}/.service/"
sqlite3 "${WORKFLOW_RUN_DIR}/.service/db" <'db.sqlite3'
workflow_run_ok "${TEST_NAME_BASE}-restart" \
    cylc play --reference-test --debug --no-detach  \
    -s "CYLC_TEST_PLATFORM='${CYLC_TEST_PLATFORM}'" "${WORKFLOW_NAME}"

purge
exit
