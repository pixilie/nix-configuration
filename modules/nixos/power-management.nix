{ ... }:

{
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

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "keep";
      CPU_SCALING_GOVERNOR_ON_BAT = "keep";
      CPU_ENERGY_PERF_POLICY_ON_AC = "keep";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "keep";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 100;
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}
