from aim_runs import aim_run, aim_run_fail

import pytest


def test_aim_run():
    aim_run()


def test_aim_run_fail():
    with pytest.raises(Exception):
        aim_run_fail()
# Capture the failure mode