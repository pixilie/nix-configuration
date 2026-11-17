{ lib }:
let
  prom = {
    type = "prometheus";
    uid = "prometheus";
  };
  loki = {
    type = "loki";
    uid = "loki";
  };

  withRefs =
    ds:
    lib.imap0 (
      i: t:
      {
        datasource = ds;
        refId = builtins.elemAt (lib.stringToCharacters "ABCDEFGHIJ") i;
      }
      // t
    );

  q = expr: legendFormat: {
    inherit expr legendFormat;
    range = true;
    instant = false;
  };

  qi = expr: {
    inherit expr;
    range = false;
    instant = true;
    format = "table";
  };

  lq = expr: legendFormat: {
    inherit expr legendFormat;
    queryType = "range";
  };

  steps =
    base: rest:
    [
      {
        color = base;
        value = null;
      }
    ]
    ++ map (s: {
      color = builtins.elemAt s 1;
      value = builtins.elemAt s 0;
    }) rest;

  pos = x: y: w: h: { inherit x y w h; };

  prop = props: lib.mapAttrsToList (id: value: { inherit id value; }) props;
  byName = name: props: {
    matcher = {
      id = "byName";
      options = name;
    };
    properties = prop props;
  };
  byRegex = re: props: {
    matcher = {
      id = "byRegexp";
      options = re;
    };
    properties = prop props;
  };

  fixed = color: {
    mode = "fixed";
    fixedColor = color;
  };
  dashed = {
    "custom.lineStyle" = {
      fill = "dash";
      dash = [
        10
        10
      ];
    };
    "custom.fillOpacity" = 0;
    "custom.stacking" = {
      mode = "none";
      group = "A";
    };
  };
  negative = {
    "custom.transform" = "negative-Y";
  };

  upDown = [
    {
      type = "value";
      options = {
        "1" = {
          text = "UP";
          color = "green";
          index = 0;
        };
        "0" = {
          text = "DOWN";
          color = "red";
          index = 1;
        };
      };
    }
  ];

  levelColors = [
    (byRegex "emerg|alert|crit" { color = fixed "dark-red"; })
    (byName "err" { color = fixed "red"; })
    (byName "warning" { color = fixed "orange"; })
    (byName "notice" { color = fixed "green"; })
    (byName "info" { color = fixed "blue"; })
    (byName "debug" { color = fixed "gray"; })
  ];

  errorLevels = "emerg|alert|crit|err";

  stat =
    {
      title,
      gridPos,
      targets,
      unit ? "none",
      decimals ? null,
      thresholds ? steps "green" [ ],
      mappings ? [ ],
      colorMode ? "value",
      graphMode ? "none",
      noValue ? null,
    }:
    {
      type = "stat";
      inherit title gridPos;
      datasource = prom;
      targets = withRefs prom targets;
      fieldConfig = {
        defaults = {
          inherit unit mappings;
          color.mode = "thresholds";
          thresholds = {
            mode = "absolute";
            steps = thresholds;
          };
        }
        // lib.optionalAttrs (decimals != null) { inherit decimals; }
        // lib.optionalAttrs (noValue != null) { inherit noValue; };
        overrides = [ ];
      };
      options = {
        reduceOptions = {
          calcs = [ "lastNotNull" ];
          fields = "";
          values = false;
        };
        inherit colorMode graphMode;
        justifyMode = "auto";
        orientation = "auto";
        textMode = "auto";
        wideLayout = true;
        showPercentChange = false;
      };
    };

  timeseries =
    {
      title,
      gridPos,
      targets,
      unit ? "short",
      stack ? false,
      fill ? 10,
      min ? 0,
      max ? null,
      overrides ? [ ],
      legend ? "list",
      calcs ? [ ],
      drawStyle ? "line",
      ds ? prom,
    }:
    {
      type = "timeseries";
      inherit title gridPos;
      datasource = ds;
      targets = withRefs ds targets;
      fieldConfig = {
        defaults = {
          inherit unit;
          color.mode = "palette-classic";
          custom = {
            inherit drawStyle;
            lineWidth = 1;
            fillOpacity = fill;
            gradientMode = "none";
            showPoints = "never";
            spanNulls = false;
            lineInterpolation = "linear";
            barAlignment = 0;
            axisBorderShow = false;
            stacking = {
              mode = if stack then "normal" else "none";
              group = "A";
            };
          };
        }
        // lib.optionalAttrs (min != null) { inherit min; }
        // lib.optionalAttrs (max != null) { inherit max; };
        inherit overrides;
      };
      options = {
        legend = {
          displayMode = legend;
          placement = "bottom";
          showLegend = true;
          inherit calcs;
        };
        tooltip = {
          mode = "multi";
          sort = "desc";
        };
      };
    };

  table =
    {
      title,
      gridPos,
      targets,
      overrides ? [ ],
      transformations ? [ ],
      sortBy ? [ ],
    }:
    {
      type = "table";
      inherit title gridPos transformations;
      datasource = prom;
      targets = withRefs prom targets;
      fieldConfig = {
        defaults = {
          custom = {
            align = "auto";
            cellOptions.type = "auto";
            inspect = false;
          };
          color.mode = "thresholds";
          thresholds = {
            mode = "absolute";
            steps = steps "green" [ ];
          };
        };
        inherit overrides;
      };
      options = {
        showHeader = true;
        cellHeight = "sm";
        inherit sortBy;
        footer = {
          show = false;
          reducer = [ "sum" ];
          fields = "";
        };
      };
    };

  bargauge =
    {
      title,
      gridPos,
      targets,
      unit,
      thresholds,
      min ? null,
      max ? null,
      ds ? prom,
    }:
    {
      type = "bargauge";
      inherit title gridPos;
      datasource = ds;
      targets = withRefs ds targets;
      fieldConfig = {
        defaults = {
          inherit unit;
          color.mode = "thresholds";
          thresholds = {
            mode = "absolute";
            steps = thresholds;
          };
        }
        // lib.optionalAttrs (min != null) { inherit min; }
        // lib.optionalAttrs (max != null) { inherit max; };
        overrides = [ ];
      };
      options = {
        orientation = "horizontal";
        displayMode = "gradient";
        valueMode = "color";
        namePlacement = "auto";
        showUnfilled = true;
        sizing = "auto";
        minVizHeight = 16;
        minVizWidth = 8;
        maxVizHeight = 300;
        reduceOptions = {
          calcs = [ "lastNotNull" ];
          fields = "";
          values = false;
        };
      };
    };

  logs = title: gridPos: expr: {
    type = "logs";
    inherit title gridPos;
    datasource = loki;
    targets = withRefs loki [
      {
        inherit expr;
        queryType = "range";
      }
    ];
    options = {
      showTime = true;
      showLabels = false;
      showCommonLabels = false;
      wrapLogMessage = true;
      prettifyLogMessage = false;
      enableLogDetails = true;
      enableInfiniteScrolling = true;
      dedupStrategy = "none";
      sortOrder = "Descending";
    };
  };

  row = title: y: {
    type = "row";
    inherit title;
    gridPos = pos 0 y 24 1;
    collapsed = false;
    panels = [ ];
  };

  textbox = name: label: {
    type = "textbox";
    inherit name label;
    query = "";
    current = {
      text = "";
      value = "";
    };
    options = [
      {
        selected = true;
        text = "";
        value = "";
      }
    ];
    hide = 0;
  };

  dashboard =
    {
      uid,
      title,
      panels,
      variables ? [ ],
      time ? "now-6h",
    }:
    {
      inherit uid title;
      tags = [ "vps" ];
      timezone = "browser";
      editable = true;
      graphTooltip = 1;
      refresh = "30s";
      schemaVersion = 41;
      version = 1;
      fiscalYearStartMonth = 0;
      liveNow = false;
      time = {
        from = time;
        to = "now";
      };
      timepicker = { };
      annotations.list = [ ];
      links = [
        {
          type = "dashboards";
          title = "VPS";
          tags = [ "vps" ];
          asDropdown = false;
          includeVars = false;
          keepTime = true;
          targetBlank = false;
          icon = "external link";
          tooltip = "";
          url = "";
        }
      ];
      templating.list = variables;
      panels = lib.imap1 (i: p: p // { id = i; }) panels;
    };

  cores = "count(count by (cpu) (node_cpu_seconds_total))";
  fsFilter = ''fstype!~"tmpfs|ramfs|autofs|efivarfs"'';
  sel = ''service="$service"'';
in
{
  server = dashboard {
    uid = "vps-server";
    title = "Serveur";
    panels = [
      (stat {
        title = "Uptime";
        gridPos = pos 0 0 3 4;
        targets = [ (q "time() - node_boot_time_seconds" "") ];
        unit = "dtdurations";
        decimals = 0;
        thresholds = steps "blue" [ ];
      })
      (stat {
        title = "CPU";
        gridPos = pos 3 0 3 4;
        targets = [ (q ''1 - avg(rate(node_cpu_seconds_total{mode="idle"}[$__rate_interval]))'' "") ];
        unit = "percentunit";
        decimals = 1;
        graphMode = "area";
        thresholds = steps "green" [
          [
            0.7
            "orange"
          ]
          [
            0.9
            "red"
          ]
        ];
      })
      (stat {
        title = "RAM";
        gridPos = pos 6 0 3 4;
        targets = [ (q "1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes" "") ];
        unit = "percentunit";
        decimals = 1;
        graphMode = "area";
        thresholds = steps "green" [
          [
            0.8
            "orange"
          ]
          [
            0.9
            "red"
          ]
        ];
      })
      (stat {
        title = "Swap";
        gridPos = pos 9 0 3 4;
        targets = [ (q "1 - node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes" "") ];
        unit = "percentunit";
        decimals = 1;
        graphMode = "area";
        thresholds = steps "green" [
          [
            0.5
            "orange"
          ]
          [
            0.8
            "red"
          ]
        ];
      })
      (stat {
        title = "Disque /";
        gridPos = pos 12 0 3 4;
        targets = [
          (q ''1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}'' "")
        ];
        unit = "percentunit";
        decimals = 1;
        thresholds = steps "green" [
          [
            0.8
            "orange"
          ]
          [
            0.9
            "red"
          ]
        ];
      })
      (stat {
        title = "Load 1m";
        gridPos = pos 15 0 3 4;
        targets = [ (q "node_load1" "") ];
        decimals = 2;
        graphMode = "area";
        thresholds = steps "green" [
          [
            4.5
            "orange"
          ]
          [
            6
            "red"
          ]
        ];
      })
      (stat {
        title = "Unités en échec";
        gridPos = pos 18 0 3 4;
        targets = [ (q ''count(node_systemd_unit_state{state="failed"} == 1) or vector(0)'' "") ];
        decimals = 0;
        colorMode = "background";
        thresholds = steps "green" [
          [
            1
            "red"
          ]
        ];
      })
      (stat {
        title = "Services down";
        gridPos = pos 21 0 3 4;
        targets = [ (q "count(service:up == 0) or vector(0)" "") ];
        decimals = 0;
        colorMode = "background";
        thresholds = steps "green" [
          [
            1
            "red"
          ]
        ];
      })

      (timeseries {
        title = "CPU par mode";
        gridPos = pos 0 4 12 8;
        targets = [
          (q ''sum by (mode) (rate(node_cpu_seconds_total{mode!="idle"}[$__rate_interval])) / scalar(${cores})'' "{{mode}}")
        ];
        unit = "percentunit";
        stack = true;
        fill = 40;
        max = 1;
      })
      (timeseries {
        title = "Load average";
        gridPos = pos 12 4 12 8;
        targets = [
          (q "node_load1" "1m")
          (q "node_load5" "5m")
          (q "node_load15" "15m")
          (q cores "Cœurs")
        ];
        overrides = [ (byName "Cœurs" (dashed // { color = fixed "red"; })) ];
      })

      (timeseries {
        title = "Mémoire";
        gridPos = pos 0 12 8 8;
        targets = [
          (q "node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes - node_memory_SReclaimable_bytes" "Utilisée")
          (q "node_memory_Buffers_bytes + node_memory_Cached_bytes + node_memory_SReclaimable_bytes" "Cache")
          (q "node_memory_MemFree_bytes" "Libre")
        ];
        unit = "bytes";
        stack = true;
        fill = 40;
        overrides = [
          (byName "Utilisée" { color = fixed "orange"; })
          (byName "Cache" { color = fixed "blue"; })
          (byName "Libre" { color = fixed "green"; })
        ];
      })
      (timeseries {
        title = "Swap (zram)";
        gridPos = pos 8 12 8 8;
        targets = [
          (q "node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes" "Utilisé")
          (q "node_memory_SwapTotal_bytes" "Total")
        ];
        unit = "bytes";
        overrides = [ (byName "Total" (dashed // { color = fixed "red"; })) ];
      })
      (timeseries {
        title = "Pression (PSI)";
        gridPos = pos 16 12 8 8;
        targets = [
          (q "rate(node_pressure_cpu_waiting_seconds_total[$__rate_interval])" "CPU")
          (q "rate(node_pressure_memory_waiting_seconds_total[$__rate_interval])" "Mémoire")
          (q "rate(node_pressure_io_waiting_seconds_total[$__rate_interval])" "IO")
        ];
        unit = "percentunit";
      })

      (timeseries {
        title = "Réseau";
        gridPos = pos 0 20 12 8;
        targets = [
          (q ''sum(rate(node_network_receive_bytes_total{device!="lo"}[$__rate_interval]))'' "Entrant")
          (q ''sum(rate(node_network_transmit_bytes_total{device!="lo"}[$__rate_interval]))'' "Sortant")
        ];
        unit = "Bps";
        min = null;
        overrides = [ (byName "Sortant" negative) ];
      })
      (timeseries {
        title = "Disque IO";
        gridPos = pos 12 20 12 8;
        targets = [
          (q ''sum(rate(node_disk_read_bytes_total{device!~"zram.*|sr.*"}[$__rate_interval]))'' "Lecture")
          (q ''sum(rate(node_disk_written_bytes_total{device!~"zram.*|sr.*"}[$__rate_interval]))'' "Écriture")
        ];
        unit = "Bps";
        min = null;
        overrides = [ (byName "Écriture" negative) ];
      })

      (bargauge {
        title = "Systèmes de fichiers";
        gridPos = pos 0 28 12 8;
        targets = [
          (q "1 - node_filesystem_avail_bytes{${fsFilter}} / node_filesystem_size_bytes{${fsFilter}}" "{{mountpoint}}")
        ];
        unit = "percentunit";
        min = 0;
        max = 1;
        thresholds = steps "green" [
          [
            0.8
            "orange"
          ]
          [
            0.9
            "red"
          ]
        ];
      })
      (table {
        title = "Unités systemd en échec";
        gridPos = pos 12 28 12 8;
        targets = [ (qi ''node_systemd_unit_state{state="failed"} == 1'') ];
        transformations = [
          {
            id = "filterFieldsByName";
            options.include.names = [
              "name"
              "service"
            ];
          }
        ];
      })

      (timeseries {
        title = "CPU par service";
        gridPos = pos 0 36 12 9;
        targets = [ (q "service:cpu_usage:rate2m" "{{service}}") ];
        unit = "percentunit";
        stack = true;
        fill = 40;
        legend = "table";
        calcs = [
          "mean"
          "max"
          "lastNotNull"
        ];
      })
      (timeseries {
        title = "RAM par service";
        gridPos = pos 12 36 12 9;
        targets = [ (q "service:memory_working_set:sum" "{{service}}") ];
        unit = "bytes";
        stack = true;
        fill = 40;
        legend = "table";
        calcs = [
          "mean"
          "max"
          "lastNotNull"
        ];
      })

      (table {
        title = "Ressources par unité systemd";
        gridPos = pos 0 45 24 12;
        targets = [
          (qi ''sum by (unit) (rate(container_cpu_usage_seconds_total{unit!=""}[5m]))'')
          (qi ''sum by (unit) (container_memory_working_set_bytes{unit!=""})'')
          (qi ''sum by (unit) (container_processes{unit!=""})'')
          (qi ''sum by (unit) (rate(container_fs_reads_bytes_total{unit!=""}[5m]))'')
          (qi ''sum by (unit) (rate(container_fs_writes_bytes_total{unit!=""}[5m]))'')
        ];
        transformations = [
          {
            id = "merge";
            options = { };
          }
          {
            id = "organize";
            options = {
              excludeByName.Time = true;
              renameByName = {
                unit = "Unité";
                "Value #A" = "CPU";
                "Value #B" = "RAM";
                "Value #C" = "Processus";
                "Value #D" = "Lecture";
                "Value #E" = "Écriture";
              };
            };
          }
        ];
        sortBy = [
          {
            displayName = "RAM";
            desc = true;
          }
        ];
        overrides = [
          (byName "CPU" {
            unit = "percentunit";
            decimals = 1;
          })
          (byName "RAM" { unit = "bytes"; })
          (byName "Lecture" { unit = "Bps"; })
          (byName "Écriture" { unit = "Bps"; })
        ];
      })
    ];
  };

  services = dashboard {
    uid = "vps-services";
    title = "Services";
    variables = [
      {
        type = "query";
        name = "service";
        label = "Service";
        datasource = prom;
        query = {
          qryType = 1;
          query = "label_values(service:up, service)";
          refId = "PrometheusVariableQueryEditor-VariableQuery";
        };
        definition = "label_values(service:up, service)";
        refresh = 1;
        sort = 1;
        multi = false;
        includeAll = false;
        current = { };
        options = [ ];
        regex = "";
      }
      (textbox "search" "Filtre des logs")
    ];
    panels = [
      (table {
        title = "Vue d'ensemble";
        gridPos = pos 0 0 24 17;
        targets = [
          (qi "service:up")
          (qi "avg_over_time(service:up[$__range])")
          (qi "max by (service) (probe_duration_seconds)")
          (qi "max by (service) (probe_http_status_code)")
          (qi "service:cpu_usage:rate2m")
          (qi "service:memory_working_set:sum")
          (qi "sum by (service) (rate(caddy_http_request_duration_seconds_count[5m]))")
          (qi "min by (service) (probe_ssl_earliest_cert_expiry) - time()")
        ];
        transformations = [
          {
            id = "merge";
            options = { };
          }
          {
            id = "organize";
            options = {
              excludeByName.Time = true;
              renameByName = {
                service = "Service";
                "Value #A" = "Statut";
                "Value #B" = "Disponibilité";
                "Value #C" = "Latence";
                "Value #D" = "Code HTTP";
                "Value #E" = "CPU";
                "Value #F" = "RAM";
                "Value #G" = "Requêtes";
                "Value #H" = "Certificat";
              };
            };
          }
        ];
        sortBy = [
          {
            displayName = "Service";
            desc = false;
          }
        ];
        overrides = [
          (byName "Service" {
            links = [
              {
                title = "Détail";
                url = "/d/vps-services/services?var-service=\${__value.raw}&\${__url_time_range}";
              }
            ];
          })
          (byName "Statut" {
            mappings = upDown;
            "custom.cellOptions" = {
              type = "color-background";
              mode = "basic";
            };
            thresholds = {
              mode = "absolute";
              steps = steps "red" [
                [
                  1
                  "green"
                ]
              ];
            };
          })
          (byName "Disponibilité" {
            unit = "percentunit";
            decimals = 2;
            "custom.cellOptions".type = "color-text";
            thresholds = {
              mode = "absolute";
              steps = steps "red" [
                [
                  0.99
                  "orange"
                ]
                [
                  0.999
                  "green"
                ]
              ];
            };
          })
          (byName "Latence" {
            unit = "s";
            "custom.cellOptions".type = "color-text";
            thresholds = {
              mode = "absolute";
              steps = steps "green" [
                [
                  0.5
                  "orange"
                ]
                [
                  1
                  "red"
                ]
              ];
            };
          })
          (byName "Code HTTP" {
            decimals = 0;
            "custom.cellOptions".type = "color-text";
            thresholds = {
              mode = "absolute";
              steps = steps "red" [
                [
                  200
                  "green"
                ]
                [
                  400
                  "orange"
                ]
                [
                  500
                  "red"
                ]
              ];
            };
          })
          (byName "CPU" {
            unit = "percentunit";
            decimals = 1;
          })
          (byName "RAM" { unit = "bytes"; })
          (byName "Requêtes" { unit = "reqps"; })
          (byName "Certificat" {
            unit = "dtdurations";
            decimals = 0;
            "custom.cellOptions".type = "color-text";
            thresholds = {
              mode = "absolute";
              steps = steps "red" [
                [
                  604800
                  "orange"
                ]
                [
                  1209600
                  "green"
                ]
              ];
            };
          })
        ];
      })
      {
        type = "state-timeline";
        title = "Historique de disponibilité";
        gridPos = pos 0 17 24 12;
        datasource = prom;
        targets = withRefs prom [ (q "service:up" "{{service}}") ];
        fieldConfig = {
          defaults = {
            mappings = upDown;
            color.mode = "thresholds";
            thresholds = {
              mode = "absolute";
              steps = steps "red" [
                [
                  1
                  "green"
                ]
              ];
            };
            custom = {
              fillOpacity = 80;
              lineWidth = 0;
            };
          };
          overrides = [ ];
        };
        options = {
          showValue = "never";
          mergeValues = true;
          alignValue = "left";
          rowHeight = 0.8;
          legend.showLegend = false;
          tooltip.mode = "single";
        };
      }
      (timeseries {
        title = "Latence des probes";
        gridPos = pos 0 29 12 8;
        targets = [ (q "max by (service) (probe_duration_seconds)" "{{service}}") ];
        unit = "s";
      })
      (timeseries {
        title = "Erreurs dans les logs";
        gridPos = pos 12 29 12 8;
        ds = loki;
        targets = [
          (lq ''sum by (service) (count_over_time({service=~".+", level=~"${errorLevels}"} [$__auto]))'' "{{service}}")
        ];
        drawStyle = "bars";
        stack = true;
        fill = 80;
      })

      (row "Détail : $service" 37)
      (stat {
        title = "Statut";
        gridPos = pos 0 38 3 4;
        targets = [ (q "service:up{${sel}}" "") ];
        mappings = upDown;
        colorMode = "background";
        thresholds = steps "red" [
          [
            1
            "green"
          ]
        ];
      })
      (stat {
        title = "Disponibilité";
        gridPos = pos 3 38 3 4;
        targets = [ (q "avg_over_time(service:up{${sel}}[$__range])" "") ];
        unit = "percentunit";
        decimals = 2;
        thresholds = steps "red" [
          [
            0.99
            "orange"
          ]
          [
            0.999
            "green"
          ]
        ];
      })
      (stat {
        title = "Latence";
        gridPos = pos 6 38 3 4;
        targets = [ (q "max(probe_duration_seconds{${sel}})" "") ];
        unit = "s";
        graphMode = "area";
        noValue = "pas de probe";
        thresholds = steps "green" [
          [
            0.5
            "orange"
          ]
          [
            1
            "red"
          ]
        ];
      })
      (stat {
        title = "Code HTTP";
        gridPos = pos 9 38 3 4;
        targets = [ (q "max(probe_http_status_code{${sel}})" "") ];
        decimals = 0;
        noValue = "-";
        thresholds = steps "red" [
          [
            200
            "green"
          ]
          [
            400
            "orange"
          ]
          [
            500
            "red"
          ]
        ];
      })
      (stat {
        title = "CPU";
        gridPos = pos 12 38 3 4;
        targets = [ (q "service:cpu_usage:rate2m{${sel}}" "") ];
        unit = "percentunit";
        decimals = 1;
        graphMode = "area";
        thresholds = steps "blue" [ ];
      })
      (stat {
        title = "RAM";
        gridPos = pos 15 38 3 4;
        targets = [ (q "service:memory_working_set:sum{${sel}}" "") ];
        unit = "bytes";
        graphMode = "area";
        thresholds = steps "blue" [ ];
      })
      (stat {
        title = "Redémarrages";
        gridPos = pos 18 38 3 4;
        targets = [ (q "round(sum(increase(node_systemd_service_restart_total{${sel}}[$__range])))" "") ];
        decimals = 0;
        noValue = "0";
        thresholds = steps "green" [
          [
            1
            "orange"
          ]
          [
            5
            "red"
          ]
        ];
      })
      (stat {
        title = "Certificat";
        gridPos = pos 21 38 3 4;
        targets = [ (q "min(probe_ssl_earliest_cert_expiry{${sel}}) - time()" "") ];
        unit = "dtdurations";
        decimals = 0;
        noValue = "-";
        thresholds = steps "red" [
          [
            604800
            "orange"
          ]
          [
            1209600
            "green"
          ]
        ];
      })

      (timeseries {
        title = "Latence par phase";
        gridPos = pos 0 42 6 8;
        targets = [ (q "sum by (phase) (probe_http_duration_seconds{${sel}})" "{{phase}}") ];
        unit = "s";
        stack = true;
        fill = 40;
      })
      (timeseries {
        title = "Requêtes HTTP par code";
        gridPos = pos 6 42 6 8;
        targets = [
          (q "sum by (code) (rate(caddy_http_request_duration_seconds_count{${sel}}[$__rate_interval]))" "{{code}}")
        ];
        unit = "reqps";
        stack = true;
        fill = 40;
        overrides = [
          (byRegex "2.." { color = fixed "green"; })
          (byRegex "3.." { color = fixed "blue"; })
          (byRegex "4.." { color = fixed "orange"; })
          (byRegex "5.." { color = fixed "red"; })
        ];
      })
      (timeseries {
        title = "CPU par unité";
        gridPos = pos 12 42 6 8;
        targets = [
          (q "sum by (unit) (rate(container_cpu_usage_seconds_total{${sel}}[$__rate_interval]))" "{{unit}}")
        ];
        unit = "percentunit";
        stack = true;
        fill = 40;
      })
      (timeseries {
        title = "RAM par unité";
        gridPos = pos 18 42 6 8;
        targets = [ (q "sum by (unit) (container_memory_working_set_bytes{${sel}})" "{{unit}}") ];
        unit = "bytes";
        stack = true;
        fill = 40;
      })

      (timeseries {
        title = "Disque par unité";
        gridPos = pos 0 50 8 7;
        targets = [
          (q "sum by (unit) (rate(container_fs_reads_bytes_total{${sel}}[$__rate_interval]))" "{{unit}} lecture")
          (q "sum by (unit) (rate(container_fs_writes_bytes_total{${sel}}[$__rate_interval]))" "{{unit}} écriture")
        ];
        unit = "Bps";
        min = null;
        overrides = [ (byRegex ".* écriture" negative) ];
      })
      (timeseries {
        title = "Volume des logs";
        gridPos = pos 8 50 16 7;
        ds = loki;
        targets = [
          (lq ''sum by (level) (count_over_time({${sel}} |~ "(?i)$search" [$__auto]))'' "{{level}}")
        ];
        drawStyle = "bars";
        stack = true;
        fill = 80;
        overrides = levelColors;
      })
      (logs "Logs : $service" (pos 0 57 24 16) ''{${sel}} |~ "(?i)$search"'')
    ];
  };

  logs = dashboard {
    uid = "vps-logs";
    title = "Logs";
    time = "now-1h";
    variables = [
      {
        type = "query";
        name = "unit";
        label = "Unité";
        datasource = loki;
        query = {
          type = 1;
          label = "unit";
          stream = ''{host="vps"}'';
          refId = "LokiVariableQueryEditor-VariableQuery";
        };
        definition = ''label_values({host="vps"}, unit)'';
        refresh = 2;
        sort = 1;
        multi = true;
        includeAll = true;
        allValue = ".*";
        current = {
          text = [ "All" ];
          value = [ "$__all" ];
        };
        options = [ ];
        regex = "";
      }
      {
        type = "custom";
        name = "level";
        label = "Niveau";
        query = "emerg,alert,crit,err,warning,notice,info,debug";
        multi = true;
        includeAll = true;
        allValue = ".*";
        current = {
          text = [ "All" ];
          value = [ "$__all" ];
        };
        options = [ ];
      }
      (textbox "search" "Recherche")
    ];
    panels =
      let
        stream = ''{host="vps", unit=~"$unit", level=~"$level"} |~ "(?i)$search"'';
      in
      [
        (timeseries {
          title = "Volume par niveau";
          gridPos = pos 0 0 24 7;
          ds = loki;
          targets = [ (lq "sum by (level) (count_over_time(${stream} [$__auto]))" "{{level}}") ];
          drawStyle = "bars";
          stack = true;
          fill = 80;
          overrides = levelColors;
        })
        (timeseries {
          title = "Volume par unité";
          gridPos = pos 0 7 12 8;
          ds = loki;
          targets = [ (lq "topk(10, sum by (unit) (count_over_time(${stream} [$__auto])))" "{{unit}}") ];
          drawStyle = "bars";
          stack = true;
          fill = 80;
        })
        (timeseries {
          title = "Erreurs par unité";
          gridPos = pos 12 7 12 8;
          ds = loki;
          targets = [
            (lq ''sum by (unit) (count_over_time({host="vps", unit=~"$unit", level=~"${errorLevels}"} |~ "(?i)$search" [$__auto]))'' "{{unit}}")
          ];
          drawStyle = "bars";
          stack = true;
          fill = 80;
        })
        (logs "Logs" (pos 0 15 24 22) stream)
      ];
  };
}
