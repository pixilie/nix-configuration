{ ... }:

{
  services.mako = {
    enable = true;

    sort = "-time";
    maxVisible = 3;
    defaultTimeout = 5000;

    font = "Noto Sans";
    backgroundColor = "#17191e";
    textColor = "#ABB2BF";
    height = 100;
    width = 300;
    borderRadius = 5;
    borderSize = 0;
    maxIconSize = 55;
    padding = "10";
  };
}
