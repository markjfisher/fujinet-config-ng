# Find all test_*.yaml files under testing/unit
UNIT_TEST_FILES := $(shell find testing/unit -name "test_*.yaml")

.PHONY: unit-test
unit-test:
	@echo "Running unit tests..."
	@tmpdir=$$(mktemp -d -t config-ng-unit.XXXXXX); \
	trap 'rm -rf "$$tmpdir"' EXIT INT TERM HUP; \
	failed=0; \
	for test in $(UNIT_TEST_FILES); do \
		echo "Running $$test..."; \
		if ! WS_ROOT=$(CURDIR) UNIT_TEST_DIR=$(CURDIR)/testing/unit \
		     soft65c02_unit -b "$$tmpdir" -i "$$test"; then \
			echo "FAILED: $$test"; \
			failed=1; \
		fi; \
	done; \
	if [ $$failed -eq 1 ]; then \
		echo "One or more tests failed"; \
		exit 1; \
	fi; \
	echo "All unit tests passed"
