{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "where-is-my-sddm-theme";
  version = "v1.11.0";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src/where_is_my_sddm_theme_qt5 $out/share/sddm/themes/where-is-my-sddm-theme
  '';
  src = fetchFromGitHub {
    owner = "stepanzubkov";
    repo = "where-is-my-sddm-theme";
    rev = "6f9a9f6884e08cbc82696fd823310c0f98622f49";
    sha256 = "EzO+MTz1PMmgeKyw65aasetmjUCpvilcvePt6HJZrpo=";
  };
}
