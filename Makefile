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
	@lua-bundler -e $(EXAMPLE_INPUT_FILE) -o $(EXAMPLE_OUTPUT_FILE);
	@echo "$(GREEN)Copying output file to clipboard...$(NC)"; \
	if [ -f "$(EXAMPLE_OUTPUT_FILE)" ]; then \
		if command -v xclip >/dev/null 2>&1; then \
			cat "$(EXAMPLE_OUTPUT_FILE)" | xclip -selection clipboard; \
			echo "$(GREEN)✓ Content copied to clipboard using xclip!$(NC)"; \
		elif command -v xsel >/dev/null 2>&1; then \
			cat "$(EXAMPLE_OUTPUT_FILE)" | xsel --clipboard --input; \
			echo "$(GREEN)✓ Content copied to clipboard using xsel!$(NC)"; \
		elif command -v wl-copy >/dev/null 2>&1; then \
			cat "$(EXAMPLE_OUTPUT_FILE)" | wl-copy; \
			echo "$(GREEN)✓ Content copied to clipboard using wl-copy (Wayland)!$(NC)"; \
		else \
			echo "$(RED)No clipboard tool found! Please install xclip, xsel, or wl-copy$(NC)"; \
			echo "$(YELLOW)Install with: sudo apt-get install xclip$(NC)"; \
		fi; \
	else \
		echo "$(RED)Output file $(EXAMPLE_OUTPUT_FILE) not found!$(NC)"; \
	fi;