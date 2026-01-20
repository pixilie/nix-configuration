{ ... }:

{
  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    temperature = {
      day = 5700;
      night = 3200;
    };
  };
}
