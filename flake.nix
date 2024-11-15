{

  description = "main nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    wakatime-lsp.url = "github:mrnossiom/wakatime-lsp";
    wakatime-lsp.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      upkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      }; # Specific pkgs only ?
    in {
      formatter = pkgs.nixfmt-unstable;

      nixosConfigurations = {
        kristen = lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/personal/configuration.nix ];
        };
      };

      homeConfigurations = {
        kristen = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            inherit upkgs;
          };
          modules = [ ./hosts/personal/personal.nix ];
        };
      };
    };
}
