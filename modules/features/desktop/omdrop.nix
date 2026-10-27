{ inputs, ... }:
{

  flake.nixosModules.omdrop = {
    imports = [ inputs.omdrop-owl.nixosModules.default ];

    services.omdrop-owl = {
      enable = true;
      allowUntested = true;
    };
  };

  flake.homeModules.omdrop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      omdrop = pkgs.callPackage ./_packages/omdrop.nix { };
      receiverUnit = "airdrop-receiver.service";

      waybarFormat = ''
        def clock: "\(. / 60 | floor):\(. % 60 | tostring | if length < 2 then "0" + . else . end)";
        (if .remaining == null then null else [.remaining - $elapsed, 0] | max end) as $left
        | {
            text: ("󰀂" + (
              if .visible != true then " …"
              elif .mode == "once" then " 1 fichier"
              elif $left != null then " " + ($left | clock)
              else "" end)),
            class: (if .visible == true then "visible" else "starting" end),
            tooltip: ((if .visible == true
              then "Visible par " + (if .visibility == "contacts" then "tes contacts" else "tout le monde" end)
                + " comme « " + (.name // "?") + " »"
              else "Démarrage d'AirDrop…" end)
              + "\nClic : arrêter · Clic droit : envoyer")
          }
      '';

      desktop = pkgs.writeShellApplication {
        name = "omdrop-desktop";
        runtimeInputs = [
          omdrop
          pkgs.jq
          pkgs.libnotify
          pkgs.coreutils
          config.programs.vicinae.package
        ];
        text = ''
          title=AirDrop
          output=
          error=

          notify() {
            notify-send --app-name="$title" "$@"
          }

          fail() {
            notify --urgency=critical "$title" "$1"
            exit 1
          }

          capture() {
            local errfile rc=0
            errfile=$(mktemp)
            output=$(omdrop "$@" 2>"$errfile") || rc=$?
            error=$(<"$errfile")
            rm -f "$errfile"
            return "$rc"
          }

          run() {
            capture "$@" || fail "''${error:-omdrop $* a échoué}"
          }

          receiving() {
            systemctl --user is-active --quiet ${receiverUnit}
          }

          send() {
            notify --expire-time=5000 "$title" "Recherche des appareils à proximité…"
            receiving || run on 10m
            run peers -n --json
            if ! jq -e 'length > 0' <<<"$output" >/dev/null; then
              fail "Aucun appareil trouvé. Ouvre la feuille de partage AirDrop sur l'iPhone puis réessaie."
            fi

            local choice
            choice=$(jq -r '.[] | "\(.name // "Appareil anonyme")  \(.mac)"' <<<"$output" \
              | vicinae dmenu --navigation-title "$title" --placeholder "Envoyer à…" --no-quick-look) || exit 0
            [[ -n "$choice" ]] || exit 0

            if capture send --pick --to "''${choice##* }"; then
              notify "$title" "Envoyé à ''${choice%  *}"
            elif [[ -n "$error" ]]; then
              fail "$error"
            fi
          }

          waybar_status() {
            local status elapsed
            while true; do
              if ! receiving; then
                echo '{"text": ""}'
                sleep 3
                continue
              fi
              status=$(omdrop status --json 2>/dev/null) || status='{}'
              for elapsed in 0 1 2 3 4 5 6 7 8 9; do
                jq -c --argjson elapsed "$elapsed" ${lib.escapeShellArg waybarFormat} <<<"$status" \
                  || echo '{"text": "󰀂"}'
                sleep 1
                receiving || break
              done
            done
          }

          case "''${1:-}" in
            toggle)
              if [[ "''${SWAYNC_TOGGLE_STATE:-}" == true ]]; then run on 10m; else run off; fi
              ;;
            state)
              if receiving; then echo true; else echo false; fi
              ;;
            off) run off ;;
            send) send ;;
            waybar) waybar_status ;;
            *)
              echo "usage: omdrop-desktop toggle|state|off|send|waybar" >&2
              exit 2
              ;;
          esac
        '';
      };

      desktopExe = lib.getExe desktop;
    in
    {
      home.packages = [ omdrop ];

      xdg.configFile."systemd/user/${receiverUnit}".source =
        "${omdrop}/share/omdrop/share/${receiverUnit}";

      services.swaync.settings.widget-config.buttons-grid.actions = lib.mkAfter [
        {
          label = "󰀂";
          type = "toggle";
          command = "${desktopExe} toggle";
          update-command = "${desktopExe} state";
        }
      ];

      xdg.desktopEntries.omdrop-send = {
        name = "Send via AirDrop";
        genericName = "AirDrop";
        exec = "${desktopExe} send";
        icon = "document-send";
        terminal = false;
        categories = [
          "Network"
          "FileTransfer"
        ];
      };

      programs.waybar.settings.main = {
        modules-right = lib.mkBefore [ "custom/airdrop" ];
        "custom/airdrop" = {
          return-type = "json";
          exec = "${desktopExe} waybar";
          on-click = "${desktopExe} off";
          on-click-right = "${desktopExe} send";
        };
      };

      programs.waybar.style = lib.mkAfter ''
        #custom-airdrop { color: @base00; background-color: @base09; }
        #custom-airdrop.starting { color: @base07; background-color: @base03; }
      '';
    };
}
