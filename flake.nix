{

  description = "main nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    wakatime-ls.url = "github:mrnossiom/wakatime-ls";
    wakatime-ls.inputs.nixpkgs.follows = "nixpkgs";

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      upkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true; # TODO: move to special packages
      };
    in {
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
