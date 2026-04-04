{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
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
    ];
}
