{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "jetbrains-toolbox"
      "steam-original"
      "steam"
      "steam-run"
      "unityhub"
      "skypeforlinux"
      "masterpdfeditor"
      "lunar-client"
    ];
}
