{

  description = "main nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    wakatime-lsp.url = "github:mrnossiom/wakatime-lsp";
    wakatime-lsp.inputs.nixpkgs.follows = "nixpkgs";
   };

  outputs = {self, nixpkgs, home-manager, ...}@inputs:
    let 
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system}; 
    in 
    {
      nixosConfigurations = {
        kristen = lib.nixosSystem {
            inherit system;
            modules = [ ./hosts/personal/configuration.nix ];
        };  
      };
      
      homeConfigurations = {
        kristen = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {inherit inputs; };
          modules = [ ./hosts/personal/personal.nix ];
        };
      };
    };
}
