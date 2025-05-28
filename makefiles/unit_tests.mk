# Find all test_*.yaml files under testing/unit
UNIT_TEST_FILES := $(shell find testing/unit -name "test_*.yaml")

# Create temp directory if it doesn't exist
/tmp/config-ng-unit:
	@mkdir -p /tmp/config-ng-unit

# Run all unit tests
.PHONY: unit-test
unit-test: /tmp/config-ng-unit
	@echo "Running unit tests..."
	@failed=0; \
	for test in $(UNIT_TEST_FILES); do \
		echo "Running $$test..."; \
		if ! WS_ROOT=$(CURDIR) UNIT_TEST_DIR=$(CURDIR)/testing/unit soft65c02_unit -b /tmp/config-ng-unit -i $$test; then \
			echo "FAILED: $$test"; \
			failed=1; \
		fi; \
	done; \
	if [ $$failed -eq 1 ]; then \
		echo "One or more tests failed"; \
		exit 1; \
	fi
	@echo "All unit tests passed"
