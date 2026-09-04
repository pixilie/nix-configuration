NIX ?= nix
NIX_FLAGS := --extra-experimental-features "nix-command flakes"

WALLPAPER := assets/media/wallpaper_dark.png

hm-switch = out=$$($(NIX) $(NIX_FLAGS) build --no-link --print-out-paths .\#homeConfigurations.$(1).activationPackage) && "$$out/activate"

i3-refresh = export PATH="$$HOME/.nix-profile/bin:$$PATH"; \
	i3-msg reload > /dev/null && feh --bg-fill $(WALLPAPER) \
	|| echo "i3 not reachable, the config will apply on next login"

.DEFAULT_GOAL := help
.PHONY: help home rebuild epita epita-light

help:
	@echo "make rebuild      NixOS system  (laptop)"
	@echo "make home         Home Manager  (laptop)"
	@echo "make epita        Home Manager  (epita)"
	@echo "make epita-light  Home Manager  (epita, minimal)"

rebuild:
	nh os switch . -H laptop

home:
	nh home switch . -c laptop

epita:
	@$(call hm-switch,epita)

epita-light:
	@$(call hm-switch,epita_light)
	@$(call i3-refresh)
