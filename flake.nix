{
  description = "main nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    wakatime-ls.url = "github:mrnossiom/wakatime-ls";
    wakatime-ls.inputs.nixpkgs.follows = "nixpkgs";

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";

    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, nixpkgs-unstable, home-manager, anyrun, ... }@inputs:
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
      templates = import ./templates;
      nixosConfigurations = {
        personal = lib.nixosSystem {
          inherit system;
          modules =
            [ ./hosts/personal/configuration.nix ];
        };
      };

      homeConfigurations = {
        personal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            inherit upkgs;
          };
          modules = [ ./hosts/personal/personal.nix ];
        };
        epita = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            inherit upkgs;
          };
          modules = [ ./hosts/epita/epita.nix ];
        };
      };
    };
}
