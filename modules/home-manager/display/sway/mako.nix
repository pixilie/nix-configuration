{ ... }:

{
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      max-icon-size = 55;
      border-radius = 5;
      padding = 10;
      border-size = 0;
      width = 300;
      height = 100;

      text-color = "#ABB2BF";
      background-color = "#17191E";

      font = "Noto Sans";
      sort = "-time";
      max-visible = 3;

      "mode=dnd" = { invisible = 1; };

      "mode=light" = {
        text-color = "#383A42";
        background-color = "#FAFAFA";
        border-color = "#E5E5E5";
      };
    };
  };
}
