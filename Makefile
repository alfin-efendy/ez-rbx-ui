# Variables
INPUT_FILE := ./main.lua
OUTPUT_FILE := ./output/bundle.lua
EXAMPLE_INPUT_FILE := ./example/main.lua
EXAMPLE_OUTPUT_FILE := ./output/example.lua


.PHONY: build
build:
	@echo "Building Lua bundle..."
	@lua-bundler -e $(INPUT_FILE) -o $(OUTPUT_FILE);

.PHONY: run
run: build
	@echo "Running example..."
	@lua-bundler -e $(EXAMPLE_INPUT_FILE) -o $(EXAMPLE_OUTPUT_FILE) -s -p 8081;

.PHONY: test
test:
	@echo "Running headless tests..."
	@for f in tests/*_test.lua; do echo "-- $$f"; lua $$f || exit 1; done

.PHONY: icons
icons:
	@echo "Generating curated icon table..."
	@node scripts/build-icons.mjs

.PHONY: verify-bundle
verify-bundle: build
	@echo "Verifying bundle under Roblox-faithful require..."
	@lua scripts/verify_bundle.lua

.PHONY: check
check: build test verify-bundle
	@echo "Check OK."

.PHONY: stress
stress: build
	@echo "Serving stress scene on :8081..."
	@lua-bundler -e ./example/stress.lua -o ./output/stress.lua -s -p 8081;

.PHONY: docs
docs:
	@echo "Serving docs (VitePress dev)..."
	@npm run docs:dev

.PHONY: docs-build
docs-build:
	@echo "Building docs site..."
	@npm run docs:build
