.PHONY: test install-deps

# Installation des dépendances
install-deps:
	luarocks install busted
	luarocks install luacov
	luarocks install luassert

# Exécution des tests
test:
	busted -c --output=gtest lua/tests/*_spec.lua

# Exécution des tests avec couverture
coverage:
	busted -c --coverage --output=gtest lua/tests/*_spec.lua
	luacov
	cat luacov.report.out
