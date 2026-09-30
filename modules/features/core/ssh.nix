{ self, inputs, ... }: {

  flake.homeModules.ssh = { config, ... }: {
    sops.secrets = {
      ssh_vps.path = "${config.home.homeDirectory}/.ssh/vps";
      ssh_rpi.path = "${config.home.homeDirectory}/.ssh/rpi";
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "*" = {
          addKeysToAgent = "yes";
        };

        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/github";
          identitiesOnly = true;
        };

        "*.epita.fr" = {
          identityFile = "~/.ssh/epita";
          identitiesOnly = true;
        };

        "vps" = {
          hostname = "vps.pixilie.net";
          user = "ubuntu";
          identityFile = "~/.ssh/vps";
        };

        "rpi" = {
          hostname = "rpi.pixilie.net";
          user = "kristen";
          identityFile = "~/.ssh/rpi";
          identitiesOnly = true;
        };

        "rpi-lan" = {
          hostname = "rpi.local";
          user = "kristen";
          identityFile = "~/.ssh/rpi";
          identitiesOnly = true;
        };
      };
    };
  };
}
