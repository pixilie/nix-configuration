{
  lib,
  src,
  rustPlatform,
  makeWrapper,
  python3,
  glib,
  keyutils,
  coreutils,
  iproute2,
  systemd,
}:

let
  python = python3.withPackages (ps: [
    ps.dbus-python
    ps.ifaddr
    ps.libarchive-c
    ps.pillow
    ps.pygobject3
    ps.zeroconf
  ]);

  runtimePath = lib.makeBinPath [
    keyutils
    coreutils
    iproute2
    systemd
  ];

  typelibs = "${glib.out}/lib/girepository-1.0";
in
rustPlatform.buildRustPackage {
  pname = "omdrop-owl";
  version = (lib.importTOML "${src}/Cargo.toml").workspace.package.version;

  inherit src;
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python ];

  postPatch = ''
    substituteInPlace crates/omdrop-owl/src/discoverable.rs \
      --replace-fail 'TOOLS: &str = "/usr/lib/omdrop"' "TOOLS: &str = \"$out/lib/omdrop\""
  '';

  buildPhase = ''
    runHook preBuild
    cargo build --frozen --release -p omdrop-owl
    runHook postBuild
  '';
  doCheck = false;

  installPhase = ''
    runHook preInstall
    PREFIX=$out TARGET=target HOOKDIR=$out/lib/omdrop/radio HELPERDIR=$out/lib/omdrop \
      sh packaging/install.sh omdrop-owl
    runHook postInstall
  '';

  postFixup = ''
    sed -i '1a export PATH=${runtimePath} GI_TYPELIB_PATH=${typelibs} PYTHONDONTWRITEBYTECODE=1' \
      $out/lib/omdrop/omdrop-discoverable

    mkdir -p $out/bin
    ln -s $out/lib/omdrop/omdrop-discoverable $out/bin/awdl-discoverable
    makeWrapper $out/lib/omdrop/send-to-peer $out/bin/send-to-peer \
      --prefix PATH : ${runtimePath} \
      --set GI_TYPELIB_PATH ${typelibs} \
      --set PYTHONDONTWRITEBYTECODE 1
  '';

  meta = {
    description = "Omdrop's radio backend on Owly: the omdrop-discoverable helper and omdrop-awdl's tools";
    homepage = "https://github.com/t4t5/owly";
    license = with lib.licenses; [
      mit
      gpl2Only
    ];
    platforms = lib.platforms.linux;
    mainProgram = "awdl-discoverable";
  };
}
