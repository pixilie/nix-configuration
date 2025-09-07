{
  description = "main nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    wakatime-ls.url = "github:mrnossiom/wakatime-ls";
    wakatime-ls.inputs.nixpkgs.follows = "nixpkgs";

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      upkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true; # TODO: move to special packages
        # config.allowUnfreePredicate = import ./lib/unfree.nix { lib = nixpkgs.lib; };
      };
    in {
      nixosConfigurations = {
        personal = lib.nixosSystem {
          inherit system;
          modules = [ ./hosts/personal/configuration.nix agenix.nixosModules.default ];
        };
      };

      homeConfigurations = {
        personal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            inherit upkgs;
          };
          modules = [ ./hosts/personal/personal.nix agenix.homeManagerModules.default ];
        };
        epita = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            inherit upkgs;
          };
          modules = [ ./hosts/epita/epita.nix agenix.homeManagerModules.default ];
        };
        epita-light = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            inherit upkgs;
          };
          modules = [ ./hosts/epita/epita-light.nix agenix.homeManagerModules.default ];
        };
      };
    };
}
