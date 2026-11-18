NIX := nix --extra-experimental-features "nix-command flakes"

SECRETS ?= secrets/secrets.yaml
RPI_HOST ?= rpi
VPS_HOST ?= kristen@vps

.DEFAULT_GOAL := help
.PHONY: help rebuild home epita-light rpi rpi-image vps secrets

help:
	@echo "make rebuild      NixOS system  (laptop)"
	@echo "make home         Home Manager  (laptop)"
	@echo "make epita-light  Home Manager  (epita)"
	@echo "make rpi          NixOS system  (raspberry pi, RPI_HOST=rpi-lan on the home network)"
	@echo "make rpi-image    Flashable SD image (raspberry pi)"
	@echo "make vps          NixOS system  (ovh vps)"
	@echo "make secrets      Edit the sops secrets (SECRETS=secrets/rpi.yaml for the pi)"

rebuild:
	nh os switch . -H laptop

home:
	nh home switch . -c laptop

epita-light:
	$$($(NIX) build --no-link --print-out-paths .#homeConfigurations.epita_light.activationPackage)/activate
	-i3-msg restart > /dev/null

rpi:
	nh os switch . -H rpi --target-host $(RPI_HOST) -e passwordless

vps:
	nh os switch . -H vps --target-host $(VPS_HOST) -e passwordless

rpi-image:
	$(NIX) build .#nixosConfigurations.rpi.config.system.build.sdImage

secrets:
	@SOPS_AGE_KEY="$$($(NIX) run nixpkgs#ssh-to-age -- -private-key -i $(HOME)/.ssh/secret)" $(NIX) run nixpkgs#sops -- $(SECRETS)
