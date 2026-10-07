{ self, inputs, ... }: {

  flake.nixosModules.veila = {
    security.pam.services.veila = { };
  };

  flake.homeModules.veila =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      screenshot = "/run/user/1000/veila-screenshot.png";

      veilaExe = lib.getExe config.programs.veila.package;
      swaymsgExe = "${pkgs.sway}/bin/swaymsg";

      lockWithScreenshot = pkgs.writeShellScript "veila-lock-screenshot" ''
        if ${veilaExe} status 2>/dev/null | ${pkgs.gnugrep}/bin/grep -qx 'active_lock=true'; then
          exit 0
        fi

        barMode=$(${swaymsgExe} -t get_bar_config bar-0 2>/dev/null | ${lib.getExe pkgs.jq} -r '.mode // "hide"')
        ${swaymsgExe} bar bar-0 mode invisible >/dev/null 2>&1
        ${pkgs.coreutils}/bin/sleep 0.15
        ${lib.getExe pkgs.grim} -t png -l 0 ${screenshot}.new && ${pkgs.coreutils}/bin/mv -f ${screenshot}.new ${screenshot}
        ${swaymsgExe} bar bar-0 mode "''${barMode:-hide}" >/dev/null 2>&1

        exec ${veilaExe} lock --wait-ready
      '';
    in
    {
      imports = [ inputs.veila.homeModules.default ];

      programs.veila = {
        enable = true;
        service.enable = true;

        idle = {
          enable = false;
          lockBeforeSleep = false;
        };

        settings = {
          theme = "normandy";

          background.path = screenshot;

          battery.enabled = true;

          weather = {
            enabled = true;
            location = "Paris";
            unit = "celsius";
          };

          visuals = {
            keyboard.enabled = false;
            battery.x = -24;

            now_playing.enabled = true;

            weather = {
              icon.enabled = true;
              temperature.enabled = true;
              location.enabled = true;
            };
          };
        };
      };

      wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
        "Mod4+Escape" = "exec ${lockWithScreenshot}";
      };

      services.swayidle = {
        timeouts = [
          {
            timeout = 180;
            command = "${lockWithScreenshot}";
          }
        ];

        events = {
          before-sleep = "${lockWithScreenshot}";
          lock = "${lockWithScreenshot}";
        };
      };
    };
}
