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