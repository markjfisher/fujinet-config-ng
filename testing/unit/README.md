# running unit tests

## running indifidual tests

```bash
export WS_ROOT=`realpath /path/to/fujinet-config-ng`
export UNIT_TEST_DIR=`realpath testing unit`
soft65c02_unit -v -b /tmp/config-ng-unit -i mod_files/scripts/test_time.yaml
```

## running all unit tests

```bash
make unit-test
```

## creating unit tests

Unit tests go in `testing/unit/tests`
