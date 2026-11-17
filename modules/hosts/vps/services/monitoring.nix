{ ... }:
{

  flake.nixosModules.vpsMonitoring =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      domain = "monitoring.pixilie.net";

      ports = {
        grafana = 3020;
        prometheus = 9090;
        node = 9002;
        blackbox = 9003;
        cadvisor = 9004;
        loki = 3100;
        lokiGrpc = 9096;
      };

      http = target: {
        module = "http_2xx";
        inherit target;
      };
      tcp = target: {
        module = "tcp_connect";
        inherit target;
      };

      monitored =
        map
          (
            s:
            {
              probe = null;
              hosts = [ ];
            }
            // s
          )
          [
            {
              name = "Caddy";
              units = [ "caddy.service" ];
            }
            {
              name = "Kalnu";
              units = [
                "kalnu.service"
                "kalnu-brouter.service"
              ];
              probe = http "https://api.kalnu.fr/health";
              hosts = [
                "kalnu.fr"
                "www.kalnu.fr"
                "api.kalnu.fr"
                "mcp.kalnu.fr"
                "mcp.admin.kalnu.fr"
              ];
            }
            {
              name = "Immich";
              units = [
                "immich-server.service"
                "immich-machine-learning.service"
                "redis-immich.service"
              ];
              probe = http "https://photos.pixilie.net/api/server/ping";
              hosts = [ "photos.pixilie.net" ];
            }
            {
              name = "OpenCloud";
              units = [ "opencloud.service" ];
              probe = http "https://cloud.pixilie.net/status.php";
              hosts = [ "cloud.pixilie.net" ];
            }
            {
              name = "Jellyfin";
              units = [ "jellyfin.service" ];
              probe = http "https://media.pixilie.net/health";
              hosts = [ "media.pixilie.net" ];
            }
            {
              name = "Dawarich";
              units = [
                "dawarich-web.service"
                "dawarich-sidekiq-all.service"
                "redis-dawarich.service"
              ];
              probe = http "https://maps.pixilie.net/api/v1/health";
              hosts = [ "maps.pixilie.net" ];
            }
            {
              name = "Vaultwarden";
              units = [ "vaultwarden.service" ];
              probe = http "https://vault.pixilie.net/alive";
              hosts = [ "vault.pixilie.net" ];
            }
            {
              name = "Miniflux";
              units = [ "miniflux.service" ];
              probe = http "https://rss.pixilie.net/healthcheck";
              hosts = [ "rss.pixilie.net" ];
            }
            {
              name = "Wakapi";
              units = [ "wakapi.service" ];
              probe = http "https://wakapi.pixilie.net/api/health";
              hosts = [ "wakapi.pixilie.net" ];
            }
            {
              name = "Rustical";
              units = [ "rustical.service" ];
              probe = http "https://rustical.pixilie.net/ping";
              hosts = [ "rustical.pixilie.net" ];
            }
            {
              name = "Calendar Syncer";
              units = [ "calendar-syncer.service" ];
              probe = http "https://calsync.pixilie.net/health";
              hosts = [ "calsync.pixilie.net" ];
            }
            {
              name = "PufferPanel";
              units = [ "pufferpanel.service" ];
              probe = http "https://games.pixilie.net";
              hosts = [ "games.pixilie.net" ];
            }
            {
              name = "Beszel";
              units = [
                "beszel-hub.service"
                "beszel-agent.service"
              ];
              probe = http "https://beszel.pixilie.net/api/health";
              hosts = [ "beszel.pixilie.net" ];
            }
            {
              name = "Vocal Time Counter";
              units = [ "vocal-time-counter.service" ];
            }
            {
              name = "Maddy";
              units = [ "maddy.service" ];
              probe = tcp "127.0.0.1:587";
            }
            {
              name = "PostgreSQL";
              units = [ "postgresql.service" ];
              probe = tcp "127.0.0.1:5432";
            }
            {
              name = "Storage Box";
              units = map (n: "mnt-storagebox-${n}.mount") [
                "immich"
                "opencloud"
                "jellyfin"
              ];
            }
            {
              name = "SSH";
              units = [
                "sshd.service"
                "fail2ban.service"
              ];
              probe = tcp "127.0.0.1:22";
            }
            {
              name = "Monitoring";
              units = [
                "grafana.service"
                "prometheus.service"
                "prometheus-node-exporter.service"
                "prometheus-blackbox-exporter.service"
                "cadvisor.service"
                "loki.service"
                "alloy.service"
              ];
              probe = http "https://${domain}/api/health";
              hosts = [ domain ];
            }
          ];

      alternation = values: "(${lib.concatMapStringsSep "|" lib.escapeRegex values})";

      toService =
        label: field: pattern:
        map (s: {
          source_labels = [ label ];
          regex = pattern (alternation s.${field});
          target_label = "service";
          replacement = s.name;
        }) (lib.filter (s: s.${field} != [ ]) monitored);

      probed = lib.filter (s: s.probe != null) monitored;

      rules = {
        groups = [
          {
            name = "services";
            rules = [
              {
                record = "service:units_active:min";
                expr = ''min by (service) (node_systemd_unit_state{state="active", service!=""})'';
              }
              {
                record = "service:probe_success:min";
                expr = ''min by (service) (probe_success{service!=""})'';
              }
              {
                record = "service:up";
                expr = ''min by (service) ({__name__=~"service:(units_active|probe_success):min"})'';
              }
              {
                record = "service:cpu_usage:rate2m";
                expr = ''sum by (service) (rate(container_cpu_usage_seconds_total{service!=""}[2m]))'';
              }
              {
                record = "service:memory_working_set:sum";
                expr = ''sum by (service) (container_memory_working_set_bytes{service!=""})'';
              }
            ];
          }
        ];
      };

      blackboxConfig = {
        modules = {
          http_2xx = {
            prober = "http";
            timeout = "10s";
            http = {
              preferred_ip_protocol = "ip4";
              ip_protocol_fallback = false;
              follow_redirects = true;
            };
          };
          tcp_connect = {
            prober = "tcp";
            timeout = "5s";
            tcp.preferred_ip_protocol = "ip4";
          };
        };
      };

      journalRules = lib.concatMapStrings (
        s:
        lib.concatMapStrings (label: ''
          rule {
            source_labels = [${builtins.toJSON label}]
            regex         = ${builtins.toJSON (alternation s.units)}
            target_label  = "service"
            replacement   = ${builtins.toJSON s.name}
          }
        '') [ "__journal_unit" "__journal__systemd_unit" ]
      ) monitored;

      dashboards = pkgs.runCommand "grafana-dashboards" { } (
        ''
          mkdir $out
        ''
        + lib.concatStrings (
          lib.mapAttrsToList (name: dashboard: ''
            cp ${pkgs.writeText "${name}.json" (builtins.toJSON dashboard)} $out/${name}.json
          '') (import ./_monitoring-dashboards.nix { inherit lib; })
        )
      );

      secretFile = name: "$__file{${config.sops.secrets.${name}.path}}";
    in
    {
      sops.secrets =
        lib.genAttrs
          [
            "grafana_admin_password"
            "grafana_secret_key"
          ]
          (_: {
            owner = "grafana";
            restartUnits = [ "grafana.service" ];
          });

      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = ports.prometheus;
        retentionTime = "30d";
        globalConfig = {
          scrape_interval = "15s";
          evaluation_interval = "15s";
        };
        ruleFiles = [ (pkgs.writeText "services.rules.json" (builtins.toJSON rules)) ];

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [ { targets = [ "127.0.0.1:${toString ports.node}" ]; } ];
            metric_relabel_configs = toService "name" "units" lib.id;
          }
          {
            job_name = "cadvisor";
            static_configs = [ { targets = [ "127.0.0.1:${toString ports.cadvisor}" ]; } ];
            metric_relabel_configs = [
              {
                source_labels = [ "__name__" ];
                regex = "container_(cpu_usage_seconds_total|memory_working_set_bytes|fs_reads_bytes_total|fs_writes_bytes_total|processes)";
                action = "keep";
              }
              {
                source_labels = [ "id" ];
                regex = "/system\\.slice/([^/]+)";
                target_label = "unit";
                replacement = "$1";
              }
            ]
            ++ toService "id" "units" (units: "/system\\.slice/${units}");
          }
          {
            job_name = "caddy";
            static_configs = [ { targets = [ "127.0.0.1:2019" ]; } ];
            metric_relabel_configs = toService "host" "hosts" lib.id;
          }
          {
            job_name = "blackbox";
            metrics_path = "/probe";
            scrape_interval = "30s";
            scrape_timeout = "15s";
            static_configs = map (s: {
              targets = [ s.probe.target ];
              labels = {
                service = s.name;
                __param_module = s.probe.module;
              };
            }) probed;
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                target_label = "__param_target";
              }
              {
                source_labels = [ "__param_target" ];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "127.0.0.1:${toString ports.blackbox}";
              }
            ];
          }
        ];

        exporters = {
          node = {
            enable = true;
            listenAddress = "127.0.0.1";
            port = ports.node;
            enabledCollectors = [ "systemd" ];
            extraFlags = [
              "--collector.systemd.enable-restarts-metrics"
              "--collector.systemd.unit-exclude=.+[.](device|scope|slice)"
            ];
          };
          blackbox = {
            enable = true;
            listenAddress = "127.0.0.1";
            port = ports.blackbox;
            configFile = pkgs.writeText "blackbox.json" (builtins.toJSON blackboxConfig);
          };
        };
      };

      services.cadvisor = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = ports.cadvisor;
        extraOptions = [
          "--docker_only=false"
          "--enable_metrics=cpu,memory,diskIO,process"
          "--housekeeping_interval=15s"
          "--store_container_labels=false"
        ];
      };

      services.loki = {
        enable = true;
        configuration =
          let
            dir = config.services.loki.dataDir;
          in
          {
            auth_enabled = false;
            analytics.reporting_enabled = false;
            server = {
              http_listen_address = "127.0.0.1";
              http_listen_port = ports.loki;
              grpc_listen_address = "127.0.0.1";
              grpc_listen_port = ports.lokiGrpc;
              log_level = "warn";
            };
            memberlist = {
              bind_addr = [ "127.0.0.1" ];
              advertise_addr = "127.0.0.1";
            };
            common = {
              path_prefix = dir;
              instance_addr = "127.0.0.1";
              replication_factor = 1;
              ring = {
                instance_addr = "127.0.0.1";
                kvstore.store = "inmemory";
              };
              storage.filesystem = {
                chunks_directory = "${dir}/chunks";
                rules_directory = "${dir}/rules";
              };
            };
            schema_config.configs = [
              {
                from = "2026-11-01";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
            limits_config = {
              retention_period = "30d";
              volume_enabled = true;
            };
            compactor = {
              working_directory = "${dir}/compactor";
              retention_enabled = true;
              delete_request_store = "filesystem";
            };
          };
      };

      services.alloy = {
        enable = true;
        extraFlags = [
          "--server.http.listen-addr=127.0.0.1:12345"
          "--disable-reporting"
        ];
      };

      environment.etc."alloy/config.alloy".text = ''
        loki.relabel "journal" {
          forward_to = []

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }

          rule {
            source_labels = ["__journal_priority_keyword"]
            target_label  = "level"
          }

        ${journalRules}
        }

        loki.source.journal "journal" {
          max_age       = "12h"
          labels        = { host = "vps" }
          relabel_rules = loki.relabel.journal.rules
          forward_to    = [loki.write.local.receiver]
        }

        loki.write "local" {
          endpoint {
            url = "http://127.0.0.1:${toString ports.loki}/loki/api/v1/push"
          }
        }
      '';

      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = ports.grafana;
            inherit domain;
            root_url = "https://${domain}/";
          };
          security = {
            admin_user = "kristen";
            admin_password = secretFile "grafana_admin_password";
            secret_key = secretFile "grafana_secret_key";
            cookie_secure = true;
            disable_gravatar = true;
          };
          users = {
            allow_sign_up = false;
            allow_org_create = false;
          };
          analytics = {
            reporting_enabled = false;
            check_for_updates = false;
            check_for_plugin_updates = false;
            feedback_links_enabled = false;
          };
          dashboards.default_home_dashboard_path = "${dashboards}/server.json";
        };

        provision = {
          enable = true;
          datasources.settings = {
            apiVersion = 1;
            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                uid = "prometheus";
                url = "http://127.0.0.1:${toString ports.prometheus}";
                isDefault = true;
                editable = false;
                jsonData = {
                  timeInterval = "15s";
                  httpMethod = "POST";
                };
              }
              {
                name = "Loki";
                type = "loki";
                uid = "loki";
                url = "http://127.0.0.1:${toString ports.loki}";
                editable = false;
                jsonData.maxLines = 1000;
              }
            ];
          };
          dashboards.settings = {
            apiVersion = 1;
            providers = [
              {
                name = "vps";
                type = "file";
                disableDeletion = true;
                allowUiUpdates = false;
                options.path = dashboards;
              }
            ];
          };
        };
      };

      services.caddy.globalConfig = ''
        metrics {
          per_host
        }
      '';

      services.caddy.virtualHosts.${domain}.extraConfig = ''
        encode zstd gzip
        reverse_proxy 127.0.0.1:${toString ports.grafana}
      '';
    };
}
