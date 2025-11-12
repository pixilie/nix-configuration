# My NixOS & home-manager configuration

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
- `modules`: Configurations parts
	- `home-manager`: Home Manager related configurations
    - `display`: Window manager related configurations
	- `nixos`: NixOS related configurations
- `pkgs`: Custom nix packages

## Switch to another profile
``` nix run nixpkgs#home-manager -- switch --flake .#<profile> ```

- `personal`: Profile for my main computer
- `epita`: Profile for school computers

## Templates

``` nix flake init --template github:/pixilie/nix-configuration#<template> ```

### Templates available :
- ``python`` : template for blank python project
- ``c`` : template for blank c project
- ``epita`` : template for epita practical in c
