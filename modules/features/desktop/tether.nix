{ inputs, ... }:
let
  tetherFor = pkgs: inputs.tether.packages.${pkgs.stdenv.hostPlatform.system}.tether;

  extension = store: slug: {
    "tether@tether.com" = {
      installation_mode = "normal_installed";
      install_url = "${store}/downloads/latest/${slug}/latest.xpi";
    };
  };
in
{

  flake.nixosModules.tether =
    { pkgs, ... }:
    {
      imports = [ inputs.tether.nixosModules.default ];

      programs.tether = {
        enable = true;
        package = tetherFor pkgs;
        wifi = {
          enable = true;
          openFirewall = true;
        };
        bluetooth.enable = true;
      };

      services.pipewire.wireplumber.extraConfig."51-no-phone-audio"."monitor.bluez.properties" = {
        "bluez5.roles" = [
          "a2dp_source"
          "bap_source"
          "hfp_ag"
        ];
      };
    };

  flake.homeModules.tether =
    { lib, pkgs, ... }:
    let
      tether = tetherFor pkgs;
    in
    {
      systemd.user.services.tetherd = {
        Unit = {
          Description = "Tether daemon, bridging an iPhone to this computer";
          After = [
            "graphical-session.target"
            "bluetooth.target"
          ];
          PartOf = [ "graphical-session.target" ];
          StartLimitIntervalSec = 60;
          StartLimitBurst = 3;
        };
        Service = {
          ExecStartPre = "-${lib.getExe' pkgs.procps "pkill"} -f ^tetherd";
          ExecStart = lib.getExe' tether "tetherd";
          Restart = "on-failure";
          RestartSec = 3;
          StandardOutput = "null";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      home.packages = [ tether ];

      programs.firefox = {
        nativeMessagingHosts = [ tether ];
        policies.ExtensionSettings = extension "https://addons.mozilla.org/firefox" "tether-browser-extension";
      };

      programs.thunderbird = {
        nativeMessagingHosts = [ tether ];
        policies.ExtensionSettings = extension "https://addons.thunderbird.net/thunderbird" "tether-mail-extension";
      };
    };
}
