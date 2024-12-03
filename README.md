# My NixOS & home-manager configuration

## TODO
- Secrets management
- Confirm menu before shutdown & reboot
- CLI tools setup (cf video) 
- better pkgs organization in personal.nix & slit beetwin home pkg (home config) and system pkg (nix config)
- config control center (cf video)
- projects's flake 
- epita computer setup
- gtk theming
- zellij config
- Bluetooth input (mouse, keyboard) not working
- swayidle

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
