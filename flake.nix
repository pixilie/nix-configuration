{
  description = "main nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wakatime-ls.url = "github:mrnossiom/wakatime-ls";
    wakatime-ls.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    kalnu.url = "git+ssh://git@github.com/pixilie/kalnu";
    kalnu.inputs.nixpkgs.follows = "nixpkgs-unstable";

    garmin-claude-mcp.url = "git+ssh://git@github.com/pixilie/garmin-claude-mcp";
    garmin-claude-mcp.inputs.nixpkgs.follows = "nixpkgs-unstable";

    calendar-syncer.url = "git+ssh://git@github.com/pixilie/calendar_syncer";
    calendar-syncer.inputs.nixpkgs.follows = "nixpkgs-unstable";

    vocal-time-counter.url = "github:pixilie/vocal-time-counter";
    vocal-time-counter.flake = false;

    helix-editor.url = "github:helix-editor/helix";
    helix-editor.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ (inputs.import-tree ./modules) ];
      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-tree;

          devShells.default = pkgs.mkShellNoCC {
            packages = [ pkgs.gnumake ];
          };
        };
    };
}
