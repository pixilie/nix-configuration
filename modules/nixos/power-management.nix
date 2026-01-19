{ ... }:

{
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
}
