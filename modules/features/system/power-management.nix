{ self, inputs, ... }:
{

  flake.nixosModules.powerManagement =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      autoCpufreqExe = lib.getExe pkgs.auto-cpufreq;

      batterySaverCpu = pkgs.writeShellScriptBin "battery-saver-cpu" ''
        case "$1" in
          on) exec ${autoCpufreqExe} --force=powersave --turbo=never ;;
          off) exec ${autoCpufreqExe} --force=reset --turbo=auto ;;
          *) echo "usage: battery-saver-cpu on|off" >&2; exit 2 ;;
        esac
      '';

      batterySaverCpuPath = "/run/current-system/sw/bin/battery-saver-cpu";
    in
    {
      environment.systemPackages = [ batterySaverCpu ];

      security.sudo.extraRules = [
        {
          groups = [ "wheel" ];
          commands = [
            {
              command = "${batterySaverCpuPath} on";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${batterySaverCpuPath} off";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      services.power-profiles-daemon.enable = false;

      services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "auto";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };

      services.upower = {
        enable = true;
        percentageLow = 10;
        percentageCritical = 5;
        timeCritical = 30;
      };
    };
}
