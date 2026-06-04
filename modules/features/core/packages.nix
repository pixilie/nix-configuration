{ self, inputs, ... }:
let
  sharedPackagesConfig =
    { lib, ... }:
    {
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "steam-original"
          "steam"
          "steam-unwrapped"
          "steam-run"
          "lunarclient"
          "libsciter"
          "castlabs-electron"
          "discord"
          "spotify"
          "rider"
          "claude-code"
          "gemini-cli"
        ];
    };
in
{
  flake.nixosModules.specialPackages = sharedPackagesConfig;
  flake.homeModules.specialPackages = sharedPackagesConfig;
}
