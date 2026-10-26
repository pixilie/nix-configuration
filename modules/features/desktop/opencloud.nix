{ self, inputs, ... }:
{

  flake.homeModules.opencloud =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      package = pkgs.opencloud-desktop.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./opencloud-no-tray.patch ];
      });
      opencloud = lib.getExe' package "opencloud";
    in
    {
      home.packages = [ package ];

      gtk.gtk3.bookmarks = lib.mkBefore [ "file://${config.home.homeDirectory}/OpenCloud OpenCloud" ];

      systemd.user.services.opencloud = {
        Unit = {
          Description = "OpenCloud desktop sync client";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = opencloud;
          ExecStop = "${opencloud} --quit";
          KillMode = "process";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
