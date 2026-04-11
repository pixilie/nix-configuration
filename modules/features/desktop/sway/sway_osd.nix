{ self, inputs, ... }: {

  flake.homeModules.sway_osd = { pkgs, ... }: {
    services.swayosd = {
      enable = true;
      stylePath = null;
    };
  };
}
