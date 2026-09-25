NIX ?= nix
NIX_FLAGS := --extra-experimental-features "nix-command flakes"

IDENTITY ?= $(HOME)/.ssh/secret

WALLPAPER := assets/media/wallpaper_dark.png

hm-switch = out=$$($(NIX) $(NIX_FLAGS) build --no-link --print-out-paths .\#homeConfigurations.$(1).activationPackage) && "$$out/activate"

i3-refresh = export PATH="$$HOME/.nix-profile/bin:$$PATH"; \
	i3-msg reload > /dev/null && feh --bg-fill $(WALLPAPER) \
	|| echo "i3 not reachable, the config will apply on next login"

.DEFAULT_GOAL := help
.PHONY: help home rebuild epita-light rpi rpi-image secrets

help:
	@echo "make rebuild      NixOS system  (laptop)"
	@echo "make home         Home Manager  (laptop)"
	@echo "make epita-light  Home Manager  (epita)"
	@echo "make rpi          NixOS system  (raspberry pi, over ssh)"
	@echo "make rpi-image    Flashable SD image (raspberry pi)"
	@echo "make secrets      Edit the sops encrypted secrets"

rebuild:
	nh os switch . -H laptop

home:
	nh home switch . -c laptop

epita-light:
	@$(call hm-switch,epita_light)
	@$(call i3-refresh)

rpi:
	nh os switch . -H rpi --target-host rpi -e passwordless

rpi-image:
	$(NIX) $(NIX_FLAGS) build .\#nixosConfigurations.rpi.config.system.build.sdImage
	@ls result/sd-image/*.img

secrets:
	@SOPS_AGE_KEY="$$($(NIX) $(NIX_FLAGS) run nixpkgs#ssh-to-age -- -private-key -i $(IDENTITY))" \
		$(NIX) $(NIX_FLAGS) run nixpkgs#sops -- secrets/secrets.yaml
