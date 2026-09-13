{ self, inputs, ... }:
{

  flake.homeModules.wakatime =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.wakatime.apiUrl = lib.mkOption {
        type = lib.types.str;
        default = "https://wakapi.pixilie.net/api";
        description = ''
          Base URL of the WakaTime compatible API heartbeats are sent to
        '';
      };

      config = {
        home.packages = [ pkgs.wakatime-cli ];

        sops.secrets.wakatime_api_key = { };

        sops.templates."wakatime.cfg" = {
          path = "${config.home.homeDirectory}/.wakatime.cfg";
          content = ''
            [settings]
            api_url = ${config.wakatime.apiUrl}
            api_key = ${config.sops.placeholder.wakatime_api_key}
          '';
        };
      };
    };
}
