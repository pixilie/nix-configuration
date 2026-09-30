{ inputs, ... }:
{

  flake.nixosModules.vpsGarminCoach =
    { config, ... }:
    let
      cfg = config.services.garmin-coach;
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
          "garmin-coach-web-dashboard.service"
        ];
      };
      sops.secrets.garmin_coach_google_client.owner = cfg.user;

      services.garmin-coach = {
        enable = true;
        dashboardDomain = "garmin.pixilie.net";
        mcpDomain = "garmin.mcp.pixilie.net";
        environmentFile = config.sops.secrets.garmin_coach_env.path;
        googleClientSecretsFile = config.sops.secrets.garmin_coach_google_client.path;
        settings.DASHBOARD_USER = "admin";
        caddy.enable = true;
      };
    };
}
