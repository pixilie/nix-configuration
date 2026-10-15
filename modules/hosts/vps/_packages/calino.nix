{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs_22,
  siteUrl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "calino";
  version = "0.39.1";

  src = fetchFromGitHub {
    owner = "Ivan-Malinovski";
    repo = "calino";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WSSLIRnoBXEBYVivy5Tjt446hhgExoxTg6vQYONe+u0=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-VB/DQoqIv5OWmoSqBr0LEHxtxrG9C/4MUPUu8N+9up4=";
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm_10
    pnpmConfigHook
  ];

  env = {
    VITE_SITE_URL = siteUrl;
    CALINO_SELF_HOSTED = "true";
    CALINO_ENABLE_SW = "false";
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/calino
    cp -r dist $out/share/calino/web
    install -Dm644 proxy/server.mjs $out/share/calino/proxy/server.mjs
    runHook postInstall
  '';
})
