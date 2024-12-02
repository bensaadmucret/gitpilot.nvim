.PHONY: test install-deps

# Installation des dépendances
install-deps:
	luarocks install busted
	luarocks install luacov
	luarocks install luassert

# Exécution des tests
test:
	LUA_PATH="./lua/?.lua;./lua/?/init.lua;./tests/?.lua;./tests/?/init.lua;./?.lua;./?/init.lua;$(LUA_PATH)" busted -c --output=gtest tests/features/*_spec.lua

# Exécution des tests avec couverture
coverage:
	busted -c --coverage --output=gtest tests/features/*_spec.lua
	luacov
	cat luacov.report.out
