# My NixOS & home-manager configuration

## TODO
- Secrets management
- zellij config
- wakatime config

## Structure
- `assets`: Files that don't fit in Nix files
  - `scripts`: Shell scripts
  - `media`: Media files
  - `config`: External configuration files
- `hosts`: Profiles configuration
  - `<profile>`: Bases configuration for a specific profile
    - `configuration.nix`: Bases for NixOS configuration
    - `<profile>.nix`: Bases for Home Manager config
    - `hardware-configuration`: Device-specific settings 
- `modules`: Configurations fragments
	- `home-manager`: Home Manager configuration fragments
    - `display`: Window manager configuration fragments
	- `nixos`: NixOS configuration fragments
- `templates`: Quickstart files

## Switch to another profile
```
nix run nixpkgs#home-manager -- switch --flake .#<profile>
```

- `personal`: Profile for my main computer
- `epita`: Profile for school computers
- `epita-light`: Profile for school computer designed to build fast
