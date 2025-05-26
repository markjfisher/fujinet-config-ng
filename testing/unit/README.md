# running unit tests

```bash
export WS_ROOT=`realpath /path/to/fujinet-config-ng`
soft65c02_unit -v -b /tmp/config-ng-unit -i mod_files/scripts/test_time.yaml
```

## creating unit tests

Unit tests go in `testing/unit/tests