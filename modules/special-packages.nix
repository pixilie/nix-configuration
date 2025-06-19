{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "jetbrains-toolbox"
      "steam-original"
      "steam"
      "steam-unwrapped"
      "steam-run"
      "unityhub"
      "lunarclient"
      "google-chrome"
      "libsciter"
      "badlion-client"
      "castlabs-electron"
      "vscode"
      "zoom"
    ];

  nixpkgs.config.permittedInsecurePackages =
    [ "dotnet-sdk-wrapped-7.0.410" "dotnet-sdk-7.0.410" ];
}
