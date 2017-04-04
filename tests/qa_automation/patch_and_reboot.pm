# SUSE's openQA tests
#
# Copyright © 2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.
#

# inherit qa_run, but overwrite run
# Summary: QA Automation: patch the system before running the test
#          This is to test Test Updates
# Maintainer: Stephan Kulow <coolo@suse.de>

use base "qa_run";
use strict;
use warnings;
use utils;
use testapi;

sub run {
    my $self = shift;

    # possibility to run as part of the aggregated tests
    if (get_var('EXTRATEST')) {
        select_console 'root-console';
    }
    else {
        $self->system_login();
    }

    pkcon_quit unless check_var('DESKTOP', 'textmode');

    for my $var (qw(OS_TEST_REPO SDK_TEST_REPO)) {
        my $repo = get_var($var);
        next unless $repo;
        assert_script_run("zypper --no-gpg-check -n ar -f '$repo' test-repo-$var");
    }

    fully_patch_system;

    type_string "reboot\n";

    # extratests excepts correctly booted SUT
    if (get_var('EXTRATEST')) {
        $self->wait_boot;
    }
}

sub test_flags {
    return {fatal => 1};
}

1;
