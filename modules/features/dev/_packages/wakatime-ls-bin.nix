{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wakatime-ls";
  version = "0.2.2";

  src = fetchurl {
    url = "https://github.com/mrnossiom/wakatime-ls/releases/download/v${finalAttrs.version}/wakatime-ls-x86_64-unknown-linux-gnu.tar.xz";
    hash = "sha256-xbi4P25K/UrEZnYzObuJa4dLvmBYs2ueO4wja0OB21U=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 wakatime-ls $out/bin/wakatime-ls
    runHook postInstall
  '';

  meta = {
    mainProgram = "wakatime-ls";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
