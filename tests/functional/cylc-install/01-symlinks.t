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

#------------------------------------------------------------------------------
# Test workflow installation symlinking localhost

. "$(dirname "$0")/test_header"

if [[ -z ${TMPDIR:-} || -z ${USER:-} || $TMPDIR/$USER == "$HOME" ]]; then
    skip_all '"TMPDIR" or "USER" not defined or "TMPDIR"/"USER" is "HOME"'
fi

set_test_number 17

create_test_global_config "" "
[install]
[[symlink dirs]]
    [[[localhost]]]
        run = \$TMPDIR/\$USER/test_cylc_symlink/cylctb_tmp_run_dir
        share = \$TMPDIR/\$USER/test_cylc_symlink/
        log = \$TMPDIR/\$USER/test_cylc_symlink/
        share/cycle = \$TMPDIR/\$USER/test_cylc_symlink/cylctb_tmp_share_dir
        work = \$TMPDIR/\$USER/test_cylc_symlink/
"

# Test "cylc install" ensure symlinks are created
TEST_NAME="${TEST_NAME_BASE}-symlinks-created"
make_rnd_workflow
run_ok "${TEST_NAME}" cylc install --flow-name="${RND_WORKFLOW_NAME}" --directory="${RND_WORKFLOW_SOURCE}"
contains_ok "${TEST_NAME}.stdout" <<__OUT__
INSTALLED $RND_WORKFLOW_NAME/run1 from ${RND_WORKFLOW_SOURCE}
__OUT__

TEST_SYM="${TEST_NAME_BASE}-run-symlink-exists-ok"

if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1") == \
    "$TMPDIR/${USER}/test_cylc_symlink/cylctb_tmp_run_dir/cylc-run/${RND_WORKFLOW_NAME}/run1" ]]; then
        ok "$TEST_SYM"
else
    fail "$TEST_SYM"
fi

TEST_SYM="${TEST_NAME_BASE}-share/cycle-symlink-exists-ok"
if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1/share/cycle") == \
"$TMPDIR/${USER}/test_cylc_symlink/cylctb_tmp_share_dir/cylc-run/${RND_WORKFLOW_NAME}/run1/share/cycle" ]]; then
    ok "$TEST_SYM"
else
    fail "$TEST_SYM"
# # Test "cylc install" ensure symlinks are created
TEST_NAME="${TEST_NAME_BASE}-symlinks-created"
make_rnd_workflow

if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1") == \
    "$TMPDIR/${USER}/test_cylc_symlink/cylctb_tmp_run_dir/cylc-run/${RND_WORKFLOW_NAME}/run1" ]]; then
        ok "$TEST_SYM"
else
    fail "$TEST_SYM"
fi

TEST_SYM="${TEST_NAME_BASE}-share/cycle-symlink-exists-ok"
if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1/share/cycle") == \
"$TMPDIR/${USER}/test_cylc_symlink/cylctb_tmp_share_dir/cylc-run/${RND_WORKFLOW_NAME}/run1/share/cycle" ]]; then
fi
if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1") == \
    "$TMPDIR/${USER}/test_cylc_symlink/cylctb_tmp_run_dir/cylc-run/${RND_WORKFLOW_NAME}/run1" ]]; then
        ok "$TEST_SYM"
else
    fail "$TEST_SYM"
fi

TEST_SYM="${TEST_NAME_BASE}-share/cycle-symlink-exists-ok"
if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1/share/cycle") == \
"$TMPDIR/${USER}/test_cylc_symlink/cylctb_tmp_share_dir/cylc-run/${RND_WORKFLOW_NAME}/run1/share/cycle" ]]; then
fi

for DIR in 'work' 'share' 'log'; do
    TEST_SYM="${TEST_NAME_BASE}-${DIR}-symlink-exists-ok"
    if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1/${DIR}") == \
   "$TMPDIR/${USER}/test_cylc_symlink/cylc-run/${RND_WORKFLOW_NAME}/run1/${DIR}" ]]; then
        ok "$TEST_SYM"
    else
        fail "$TEST_SYM"
    fi
done
rm -rf "${TMPDIR}/${USER}/test_cylc_symlink/"
purge_rnd_workflow

# test cli --symlink-dirs overrides the glblcfg
VAR=$TMPDIR/$USER/test_cylc_cli_symlink/

TEST_NAME="${TEST_NAME_BASE}-symlinks-cli-opt"
make_rnd_workflow
run_ok "${TEST_NAME}" cylc install --flow-name="${RND_WORKFLOW_NAME}" \
--directory="${RND_WORKFLOW_SOURCE}" \
--symlink-dirs="run= ${VAR}run, log=${VAR}, share=${VAR}, work = ${VAR}, share/cycle=${VAR}cylctb_tmp_share_dir"
contains_ok "${TEST_NAME}.stdout" <<__OUT__
INSTALLED $RND_WORKFLOW_NAME/run1 from ${RND_WORKFLOW_SOURCE}
__OUT__

TEST_SYM="${TEST_NAME_BASE}-share-cycle-symlink-cli-ok"
if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1/share/cycle") == \
"$TMPDIR/${USER}/test_cylc_symlink/cylctb_tmp_share_dir/cylc-run/${RND_WORKFLOW_NAME}/share/cycle" ]]; then
    fail "$TEST_SYM"
else
    ok "$TEST_SYM"
fi

for DIR in 'work' 'share' 'log'; do
    TEST_SYM="${TEST_NAME_BASE}-${DIR}-symlink-cli-ok"
    if [[ $(readlink "$HOME/cylc-run/${RND_WORKFLOW_NAME}/run1/${DIR}") == \
   "$TMPDIR/${USER}/test_cylc_cli_symlink/cylc-run/${RND_WORKFLOW_NAME}/run1/${DIR}" ]]; then
        ok "$TEST_SYM"
    else
        fail "$TEST_SYM"
    fi
done
rm -rf "${TMPDIR}/${USER}/test_cylc_cli_symlink/"
purge_rnd_workflow
