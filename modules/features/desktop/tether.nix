{ inputs, ... }:
let
  tetherFor =
    pkgs:
    inputs.tether.packages.${pkgs.stdenv.hostPlatform.system}.tether.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./tether-no-tray.patch ];
    });

  extension = store: slug: {
    "tether@tether.com" = {
      installation_mode = "normal_installed";
      install_url = "${store}/downloads/latest/${slug}/latest.xpi";
    };
  };
in
{

  flake.nixosModules.tether =
    { config, pkgs, ... }:
    {
      imports = [ inputs.tether.nixosModules.default ];

      programs.tether = {
        enable = true;
        package = tetherFor pkgs;
        wifi = {
          enable = true;
          openFirewall = true;
        };
        bluetooth.enable = true;
      };

      hardware.bluetooth = {
        disabledPlugins = [ "hostname" ];
        settings.General = {
          Class = "0x000408";
          Name = config.networking.hostName;
        };
      };

      services.pipewire.wireplumber.extraConfig."51-no-phone-audio"."monitor.bluez.properties" = {
        "bluez5.roles" = [
          "a2dp_source"
          "bap_source"
          "hfp_ag"
        ];
      };
    };

  flake.homeModules.tether =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      tether = tetherFor pkgs;
      swayncClientExe = "${config.services.swaync.package}/bin/swaync-client";

      phoneFormat = ''
        def battery_icon: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"][. / 10 | floor];
        def signal_icon: ["󰢿", "󰢼", "󰢼", "󰢽", "󰢽", "󰢾"][. | if . > 5 then 5 elif . < 0 then 0 else . end];

        ($connection.calls // {}) as $calls
        | ([$snapshot.connected_clients[]? | select(.paired)] | first) as $wifi
        | ($connection.classic_connected == true or $connection.le_connected == true) as $bluetooth
        | (if $battery != null then $battery.data
           elif $calls.available == true and ($calls.battery // 0) > 0 then $calls.battery * 20
           else null end) as $level
        | ($name.data // $wifi.device_name // "iPhone" | @html) as $phone
        | if ($status | has("command") | not) or ($bluetooth or $wifi != null | not) then empty
          else
            "<b>󰄜  \($phone)</b>\n<small>"
            + ([
                (if $level != null then "\($level | battery_icon) \($level) %" else empty end),
                (if $calls.available == true and $calls.indicators != false
                 then "\($calls.signal // 0 | signal_icon) \($calls.operator // "" | @html)"
                   + (if $calls.roaming == true then " (itinérance)" else "" end)
                 else empty end),
                (if $bluetooth then "󰂱 Bluetooth" else empty end),
                (if $wifi != null then "󰖩 Wi-Fi" else empty end)
              ] | join("   "))
            + "</small>"
          end
      '';

      phoneStatus = pkgs.writeShellApplication {
        name = "tether-phone-status";
        runtimeInputs = [
          pkgs.socat
          pkgs.jq
          pkgs.coreutils
          pkgs.systemd
        ];
        text = ''
          socket="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/tether/tetherd.sock"
          [[ -S "$socket" ]] || exit 0

          query() {
            local reply
            reply=$(printf '{"command":"%s"}\n' "$1" | timeout 2 socat -t1 - "UNIX-CONNECT:$socket" 2>/dev/null | head -n 1) || true
            jq -ce 'objects' <<<"$reply" 2>/dev/null || echo '{}'
          }

          bluez() {
            busctl --system --json=short get-property org.bluez "$1" "$2" "$3" 2>/dev/null || echo null
          }

          status=$(query bt_status)
          connection=$(query bt_connection)
          snapshot=$(query state_snapshot)

          name=null
          battery=null
          address=$(jq -r '.device_address // ""' <<<"$status")
          if [[ -n "$address" ]]; then
            device="/org/bluez/$(jq -r '.capability.adapter_id // "hci0"' <<<"$status")/dev_''${address//:/_}"
            name=$(bluez "$device" org.bluez.Device1 Alias)
            battery=$(bluez "$device" org.bluez.Battery1 Percentage)
          fi

          jq -nr \
            --argjson status "$status" \
            --argjson connection "$connection" \
            --argjson snapshot "$snapshot" \
            --argjson name "$name" \
            --argjson battery "$battery" \
            ${lib.escapeShellArg phoneFormat}
        '';
      };

      openTether = pkgs.writeShellScript "swaync-tether" ''
        ${swayncClientExe} --close-panel
        ${pkgs.coreutils}/bin/sleep 0.3
        exec ${lib.getExe' tether "tether-gtk"}
      '';
    in
    {
      systemd.user.services.tetherd = {
        Unit = {
          Description = "Tether daemon, bridging an iPhone to this computer";
          After = [
            "graphical-session.target"
            "bluetooth.target"
          ];
          PartOf = [ "graphical-session.target" ];
          StartLimitIntervalSec = 60;
          StartLimitBurst = 3;
        };
        Service = {
          ExecStartPre = "-${lib.getExe' pkgs.procps "pkill"} -f ^tetherd";
          ExecStart = lib.getExe' tether "tetherd";
          Restart = "on-failure";
          RestartSec = 3;
          StandardOutput = "null";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      home.packages = [ tether ];

      programs.firefox = {
        nativeMessagingHosts = [ tether ];
        policies.ExtensionSettings = extension "https://addons.mozilla.org/firefox" "tether-browser-extension";
      };

      programs.thunderbird = {
        nativeMessagingHosts = [ tether ];
        policies.ExtensionSettings = extension "https://addons.thunderbird.net/thunderbird" "tether-mail-extension";
      };

      services.swaync.settings = {
        widgets = lib.mkAfter [ "label#phone" ];
        widget-config."label#phone" = {
          max-lines = 2;
          use-markup = true;
          update-command = lib.getExe phoneStatus;
          command = "${openTether}";
        };
      };

      services.swaync.style = lib.mkAfter ''
        .widget-label.phone {
          margin: 0 14px 12px;
          padding: 8px 12px;
          border: 1px solid var(--noti-border-color);
          border-radius: var(--border-radius);
          background: var(--tile-bg);
        }
        .widget-label.phone:hover { background: var(--tile-bg-hover); }
        .widget-label.phone > label {
          font-family: "Noto Sans", "CaskaydiaCove Nerd Font Propo";
          font-size: 14px;
          color: var(--text-color);
        }
      '';
    };
}
