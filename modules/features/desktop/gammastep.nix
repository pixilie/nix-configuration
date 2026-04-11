{ self, inputs, ... }: {

  flake.homeModules.gammastep = { pkgs, ... }: {
    services.gammastep = {
      enable = true;
      provider = "geoclue2";

      temperature = {
        day = 5700;
        night = 3200;
      };

      settings = {
        general.fade = "1";
      };

      settings.general.method = "wayland";
    };
  };
}
