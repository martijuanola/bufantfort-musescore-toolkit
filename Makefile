
MUSESCORE4_USER_FOLDER_ROOT ?= /Users/martijuanola/Documents/Music/MuseScore4

.DEFAULT_GOAL := help
.PHONY: help install uninstall

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install   Install project templates, styles and plugins"
	@echo "  uninstall Uninstall project templates, styles and plugins"
	@echo "  help      Show this help message"

install:
	@echo "Installing the project..."
	bash scripts/install.sh $(MUSESCORE4_USER_FOLDER_ROOT)

# install other things/only certain things

uninstall:
	@echo "Uninstalling the project..."
	# Add uninstallation commands here, e.g., removing files from the appropriate directories