{ self, inputs, ... }: {

  flake.homeModules.kanshi = {
    services.kanshi = {
      enable = true;
      settings = [
        {
          profile.name = "laptop";
          profile.outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              mode = "1920x1080@60.033Hz";
              position = "0,0";
            }
          ];
        }
        {
          profile.name = "desk";
          profile.outputs = [
            {
              criteria = "Microstep MSI MAG241C 0x0000007A";
              mode = "1920x1080@60.000Hz";
              position = "0,0";
            }
            {
              criteria = "Dell Inc. DELL U2724D 5TG9H34";
              mode = "2560x1440@59.951Hz";
              position = "1920,0";
            }
            {
              criteria = "eDP-1";
              status = "disable";
            }
          ];
        }
      ];
    };
  };
}
