{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "jetbrains-toolbox"
      "steam-original"
      "steam"
      "steam-unwrapped"
      "steam-run"
      "lunarclient"
      "google-chrome"
      "libsciter"
      "castlabs-electron"
      "vscode"
      "discord"
    ];

  nixpkgs.config.permittedInsecurePackages =
    [ "dotnet-sdk-wrapped-7.0.410" "dotnet-sdk-7.0.410" ];
}
