{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writeShellApplication,
  python3,
  glib,
  keyutils,
  bash,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  util-linux,
  procps,
  iproute2,
  openssl,
  libheif,
  wl-clipboard,
  xdg-utils,
  libnotify,
}:

let
  python = python3.withPackages (ps: [
    ps.libarchive-c
    ps.pygobject3
  ]);

  notificationSend = writeShellApplication {
    name = "omarchy-notification-send";
    runtimeInputs = [ libnotify ];
    text = ''
      args=(--app-name=AirDrop)
      positional=()
      command=()
      while (( $# )); do
        case "$1" in
          -t) args+=(--expire-time="$2"); shift 2 ;;
          --image) args+=(--hint="string:image-path:$2"); shift 2 ;;
          --exec) shift; command=("$@"); break ;;
          *) positional+=("$1"); shift ;;
        esac
      done

      if (( ''${#command[@]} == 0 )); then
        exec notify-send "''${args[@]}" "''${positional[@]}"
      fi

      if [[ "$(notify-send "''${args[@]}" --action=default=Ouvrir --wait "''${positional[@]}")" == default ]]; then
        exec "''${command[@]}"
      fi
    '';
  };

  runtimePath = lib.makeBinPath [
    python
    bash
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    util-linux
    procps
    iproute2
    openssl
    libheif
    wl-clipboard
    xdg-utils
    notificationSend
  ];

  libkeyutils = "${lib.getLib keyutils}/lib/libkeyutils.so.1";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omdrop";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "netmojo-systems";
    repo = "omdrop-plugin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T0TZKuWpDwBHcNuFulMEgnuN86R16FVsx8mwSvhtjEs=";
  };

  buildInputs = [
    bash
    python
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    plugin=$out/share/omdrop
    mkdir -p $plugin $out/bin
    cp -r bin share skills manifest.json README.md LICENSE $plugin/
    ln -s ../share/omdrop/bin/omdrop $out/bin/omdrop

    substituteInPlace $plugin/bin/omdrop \
      --replace-fail '/usr/bin/python3}' '${python}/bin/python3}' \
      --replace-fail 'ctypes.CDLL("libkeyutils.so.1")' 'ctypes.CDLL("${libkeyutils}")' \
      --replace-fail heif-convert heif-dec
    sed -i '1a export PATH=${runtimePath}:$PATH GI_TYPELIB_PATH=${glib.out}/lib/girepository-1.0 PYTHONDONTWRITEBYTECODE=1' \
      $plugin/bin/omdrop

    substituteInPlace $plugin/bin/identity.py \
      --replace-fail "ctypes.CDLL('libkeyutils.so.1'" "ctypes.CDLL('${libkeyutils}'"

    substituteInPlace $plugin/share/airdrop-receiver.service \
      --replace-fail @PLUGIN_DIR@ $plugin \
      --replace-fail 'ExecStart=/usr/bin/python3 ' 'ExecStart=${python}/bin/python3 ' \
      --replace-fail '[Service]' $'[Service]\nEnvironment=PATH=${runtimePath}'

    patchShebangs $plugin/bin

    runHook postInstall
  '';

  meta = {
    description = "AirDrop CLI and receiver for Linux, from the Omarchy omdrop plugin";
    homepage = "https://github.com/netmojo-systems/omdrop-plugin";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "omdrop";
  };
})
