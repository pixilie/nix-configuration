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
  version = "0.35.0";

  src = fetchFromGitHub {
    owner = "Ivan-Malinovski";
    repo = "calino";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iIqZ7hcEml4p7H9IgArzm1v3IcBQCQjEXkiwGcPkgWI=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-YPz46fYGSoZptQXnsXFWySDgVjx1VTIT11T6l0dYGZA=";
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
