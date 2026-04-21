{ self, inputs, ... }: {

  flake.nixosModules.nh = { ... }: {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 3";
      flake = "/home/kristen/chemin/vers/ton/nix-configuration";
    };
  };
}

