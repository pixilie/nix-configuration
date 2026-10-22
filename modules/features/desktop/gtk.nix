{ self, inputs, ... }: {

  flake.homeModules.gtk =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      themes = {
        dark = {
          name = "OneDark";
          fg = "#abb2bf";
          fgMuted = "#5c6370";
          window = "#282c34";
          windowAlt = "#21252b";
          view = "#21252b";
          viewAlt = "#2c313a";
          button = "#353b45";
          buttonAlt = "#3e4451";
          header = "#21252b";
          tooltip = "#1e2127";
          light = "#3e4451";
          midlight = "#353b45";
          mid = "#21252b";
          dark = "#181a1f";
          shadow = "#0e0f12";
          accent = "#61afef";
          accentFg = "#1e2127";
          accentMuted = "#3e4451";
          visited = "#c678dd";
          negative = "#e06c75";
          neutral = "#d19a66";
          positive = "#98c379";
        };
        light = {
          name = "OneLight";
          fg = "#383a42";
          fgMuted = "#a0a1a7";
          window = "#f0f0f1";
          windowAlt = "#e5e5e6";
          view = "#ffffff";
          viewAlt = "#f5f5f6";
          button = "#e5e5e6";
          buttonAlt = "#dcdce0";
          header = "#e5e5e6";
          tooltip = "#fafafa";
          light = "#ffffff";
          midlight = "#f5f5f6";
          mid = "#dcdce0";
          dark = "#c2c2c6";
          shadow = "#9d9da3";
          accent = "#4078f2";
          accentFg = "#ffffff";
          accentMuted = "#dcdce0";
          visited = "#a626a4";
          negative = "#e45649";
          neutral = "#986801";
          positive = "#50a14f";
        };
      };

      qtctDirs = [
        "qt5ct"
        "qt6ct"
      ];

      qtRoles = [
        "windowText"
        "button"
        "light"
        "midlight"
        "dark"
        "mid"
        "text"
        "brightText"
        "buttonText"
        "base"
        "window"
        "shadow"
        "highlight"
        "highlightedText"
        "link"
        "linkVisited"
        "alternateBase"
        "noRole"
        "toolTipBase"
        "toolTipText"
        "placeholderText"
      ];

      qtPalette =
        t:
        let
          group =
            {
              fg,
              highlight,
              highlightedText,
            }:
            let
              colors = {
                inherit highlight highlightedText;
                windowText = fg;
                inherit (t)
                  button
                  light
                  midlight
                  dark
                  mid
                  window
                  shadow
                  ;
                text = fg;
                brightText = "#ffffff";
                buttonText = fg;
                base = t.view;
                link = t.accent;
                linkVisited = t.visited;
                alternateBase = t.viewAlt;
                noRole = "#000000";
                toolTipBase = t.tooltip;
                toolTipText = t.fg;
                placeholderText = t.fgMuted;
              };
            in
            lib.concatMapStringsSep ", " (role: colors.${role}) qtRoles;

          active = group {
            inherit (t) fg;
            highlight = t.accent;
            highlightedText = t.accentFg;
          };
        in
        ''
          [ColorScheme]
          active_colors=${active}
          inactive_colors=${active}
          disabled_colors=${
            group {
              fg = t.fgMuted;
              highlight = t.accentMuted;
              highlightedText = t.fgMuted;
            }
          }
        '';

      kdeColorScheme =
        t:
        let
          colorSet = background: alternate: {
            BackgroundNormal = background;
            BackgroundAlternate = alternate;
            ForegroundNormal = t.fg;
            ForegroundInactive = t.fgMuted;
            ForegroundActive = t.accent;
            ForegroundLink = t.accent;
            ForegroundVisited = t.visited;
            ForegroundNegative = t.negative;
            ForegroundNeutral = t.neutral;
            ForegroundPositive = t.positive;
            DecorationFocus = t.accent;
            DecorationHover = t.accent;
          };
        in
        lib.generators.toINI { } {
          General = {
            ColorScheme = t.name;
            Name = t.name;
          };
          "ColorEffects:Inactive".Enable = false;
          "Colors:Window" = colorSet t.window t.windowAlt;
          "Colors:View" = colorSet t.view t.viewAlt;
          "Colors:Button" = colorSet t.button t.buttonAlt;
          "Colors:Header" = colorSet t.header t.window;
          "Colors:Tooltip" = colorSet t.tooltip t.window;
          "Colors:Selection" = colorSet t.accent t.accent // {
            ForegroundNormal = t.accentFg;
            ForegroundInactive = t.accentFg;
          };
        };

      qtctSettings = qtct: style: {
        Appearance = {
          inherit style;
          custom_palette = true;
          color_scheme_path = "${config.xdg.configHome}/${qtct}/colors.conf";
          icon_theme = config.gtk.iconTheme.name;
          standard_dialogs = "xdgdesktopportal";
        };
        Fonts = {
          general = ''"${config.gtk.font.name},${toString config.gtk.font.size}"'';
          fixed = ''"CaskaydiaCove Nerd Font Mono,12"'';
        };
      };
    in
    {
      gtk = {
        enable = true;

        iconTheme = {
          name = "Arc";
          package = pkgs.arc-icon-theme;
        };

        cursorTheme = {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 24;
        };

        font = {
          name = "Cantarell";
          size = 12;
        };
      };

      qt = {
        enable = true;
        platformTheme = {
          name = "qtct";
          package = [
            pkgs.libsForQt5.qt5ct
            (pkgs.qt6Packages.qt6ct.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [ ./qt6ct-color-scheme.patch ];
            }))
          ];
        };
        style.package = pkgs.darkly;
        qt5ctSettings = qtctSettings "qt5ct" "Fusion";
        qt6ctSettings = qtctSettings "qt6ct" "Darkly";
      };

      xdg.configFile = lib.mergeAttrsList (
        lib.mapCartesianProduct
          (
            { qtct, mode }:
            {
              "${qtct}/colors/${mode}.conf".text = qtPalette themes.${mode};
            }
          )
          {
            qtct = qtctDirs;
            mode = lib.attrNames themes;
          }
      );

      xdg.dataFile = lib.mapAttrs' (
        _: t: lib.nameValuePair "color-schemes/${t.name}.colors" { text = kdeColorScheme t; }
      ) themes;

      home.activation.qtTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        for qtct in ${toString qtctDirs}; do
          dir="${config.xdg.configHome}/$qtct"
          if [ ! -e "$dir/colors.conf" ]; then
            run install -m 644 "$dir/colors/dark.conf" "$dir/colors.conf"
          fi
        done
        if [ ! -e "${config.xdg.configHome}/kdeglobals" ]; then
          run install -m 644 "${config.xdg.dataHome}/color-schemes/${themes.dark.name}.colors" "${config.xdg.configHome}/kdeglobals"
        fi
      '';

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
      };
    };
}
