{ pkgs, inputs, ... }:

{
  programs.anyrun = {
    enable = true;

    config = {
      plugins = [
        inputs.anyrun.packages.${pkgs.system}.applications
        inputs.anyrun.packages.${pkgs.system}.websearch
        inputs.anyrun.packages.${pkgs.system}.dictionary
        inputs.anyrun.packages.${pkgs.system}.shell
      ];

      x.fraction = 0.5;
      y.fraction = 0.2;
      width.fraction = 0.3;

      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = false;
      maxEntries = null;
    };

    extraCss = ''
      * {
        all: unset;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 1.1rem;
      }

      #window {
        background: rgba(30, 30, 46, 0.9);
        border-radius: 12px;
        border: 2px solid #cba6f7;
      }

      box#main {
        padding: 12px;
      }

      entry#entry {
        background: rgba(24, 24, 37, 1);
        border-radius: 8px;
        padding: 8px 16px;
        color: #cdd6f4;
      }

      list#mainlist {
        margin-top: 12px;
      }

      row.match {
        padding: 8px;
        border-radius: 8px;
        color: #cdd6f4;
      }

      row.match:selected {
        background: rgba(203, 166, 247, 0.2);
        color: #cba6f7;
      }
    '';
  };
}
