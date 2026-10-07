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
          lock.hide_cursor = true;

          background = {
            path = screenshot;
            blur_strength = 8;
            dim_strength = 35;
          };

          battery.enabled = true;
          weather.enabled = false;

          visuals = {
            avatar.enabled = false;
            username.enabled = false;

            clock = {
              format = "24h";
              font_family = "Noto Sans";
              font_weight = 600;
              font_size = 96;
              color = "#DCDFE4";
              halign = "center";
              valign = "center";
              x = 0;
              y = -110;
            };

            date = {
              format = "long";
              font_family = "Noto Sans";
              font_weight = 400;
              font_size = 20;
              color = "#ABB2BF";
              halign = "center";
              valign = "center";
              x = 0;
              y = -40;
            };

            input = {
              placeholder = "Password";
              background_color = "rgba(30, 33, 39, 0.72)";
              width = 340;
              height = 56;
              radius = 10;
              mask_color = "#61AFEF";
              font_family = "Noto Sans";
              font_weight = 400;
              font_size = 17;
              halign = "center";
              valign = "center";
              x = 0;
              y = 50;
            };

            placeholder.color = "rgba(171, 178, 191, 0.85)";
            eye.color = "rgba(171, 178, 191, 0.72)";
            caps_lock.color = "#D19A66";

            status = {
              mode = "inline";
              rejected_color = "#E06C75";
              pending_color = "#ABB2BF";
            };

            keyboard = {
              background_color = "rgba(30, 33, 39, 0.72)";
              color = "#ABB2BF";
            };

            battery = {
              background_color = "rgba(30, 33, 39, 0.72)";
              color = "#98C379";
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
