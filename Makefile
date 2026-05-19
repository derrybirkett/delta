.PHONY: run-product run-developer run-cycle docker-build docker-cycle

DELTA_SCRIPTS := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))/scripts

run-product:
	@bash $(DELTA_SCRIPTS)/run-product.sh

run-developer:
	@bash $(DELTA_SCRIPTS)/run-developer.sh

run-cycle:
	@bash $(DELTA_SCRIPTS)/run-cycle.sh

docker-build:
	@docker compose -f docker/compose.yml build

docker-cycle:
	@docker compose -f docker/compose.yml run --rm delta
