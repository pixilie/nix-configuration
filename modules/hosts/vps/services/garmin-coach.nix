{ inputs, ... }:
{

  flake.nixosModules.vpsGarminCoach =
    { config, lib, ... }:
    let
      cfg = config.services.garmin-coach;
      dashboard = "garmin-coach-web-dashboard.service";
    in
    {
      imports = [ inputs.garmin-claude-mcp.nixosModules.default ];

      sops.secrets.garmin_coach_env = {
        owner = cfg.user;
        restartUnits = [
          "garmin-coach-garmin-service.service"
          "garmin-coach-calendar-service.service"
          "garmin-coach-sync-worker.service"
          "garmin-coach-mcp-gateway.service"
          dashboard
        ];
      };
      sops.secrets.garmin_coach_google_client.owner = cfg.user;

      sops.templates."garmin-coach-smtp.env" = {
        restartUnits = [ dashboard ];
        content = ''
          SMTP_HOST=127.0.0.1
          SMTP_PORT=587
          SMTP_SECURITY=none
          SMTP_USERNAME=noreply@pixilie.net
          SMTP_PASSWORD=${config.sops.placeholder.maddy_noreply_password}
          SMTP_FROM=noreply@pixilie.net
          SMTP_FROM_NAME=Garmin Coach
        '';
      };

      systemd.services.garmin-coach-web-dashboard = {
        after = [ "maddy.service" ];
        serviceConfig.EnvironmentFile = lib.mkAfter [
          config.sops.templates."garmin-coach-smtp.env".path
        ];
      };

      services.garmin-coach = {
        enable = true;
        dashboardDomain = "garmin.pixilie.net";
        mcpDomain = "garmin.mcp.pixilie.net";
        environmentFile = config.sops.secrets.garmin_coach_env.path;
        googleClientSecretsFile = config.sops.secrets.garmin_coach_google_client.path;
        settings.DASHBOARD_USER = "kristen.couty@gmail.com";
        caddy.enable = true;
      };
    };
}
