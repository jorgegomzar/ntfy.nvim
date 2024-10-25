TESTS_DIR=tests
TESTS_INIT=${TESTS_DIR}/minimal_init.lua

.PHONY: test

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR}/ { minimal_init = '${TESTS_INIT}' }"
