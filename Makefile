.PHONY: test test-unit test-integration install-deps coverage

BUSTED=/usr/local/bin/busted
LUA_PATH_CONFIG=./lua/?.lua;./lua/?/init.lua;./tests/?.lua;./tests/?/init.lua;./?.lua;./?/init.lua;$(LUA_PATH)

# Installation des dépendances
install-deps:
	luarocks install busted
	luarocks install luacov
	luarocks install luassert

# Exécution de tous les tests
test:
	@echo "Running all tests..."
	@BUSTED=true LUA_PATH="$(LUA_PATH_CONFIG)" $(BUSTED) -c --output=gtest tests/features/*_spec.lua

# Exécution des tests unitaires uniquement
test-unit:
	@echo "Running unit tests..."
	@BUSTED=true LUA_PATH="$(LUA_PATH_CONFIG)" $(BUSTED) -c --output=gtest --tags=unit tests/features/*_spec.lua

# Exécution des tests d'intégration uniquement
test-integration:
	@echo "Running integration tests..."
	@BUSTED=true LUA_PATH="$(LUA_PATH_CONFIG)" $(BUSTED) -c --output=gtest --tags=integration tests/features/*_spec.lua

# Exécution des tests avec couverture
coverage:
	@echo "Running tests with coverage..."
	@BUSTED=true LUA_PATH="$(LUA_PATH_CONFIG)" $(BUSTED) -c --coverage --output=gtest tests/features/*_spec.lua
	@luacov
	@echo "Coverage report:"
	@cat luacov.report.out
