{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "sf-fonts";
  version = "1";
  pro = pkgs.fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
    sha256 = "sha256-Mu0pmx3OWiKBmMEYLNg+u2MxFERK07BQGe3WAhEec5Q=";
  };
  mono = pkgs.fetchFromGitHub {
    owner = "shaunsingh";
    repo = "SFMono-Nerd-Font-Ligaturized";
    rev = "dc5a3e6fcc2e16ad476b7be3c3c17c2273b260ea";
    sha256 = "sha256-AYjKrVLISsJWXN6Cj74wXmbJtREkFDYOCRw1t2nVH2w=";
  };
  buildInputs = [ pkgs.p7zip ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/usr/share/fonts/OTF $out/usr/share/fonts/TTF
    7z x $pro
    7z x SFProFonts/SF\ Pro\ Fonts.pkg
    7z x Payload~
    mkdir -p $out/fontfiles
    mv Library/Fonts/* $out/usr/share/fonts/OTF
    cp -R $mono/*.otf $out/usr/share/fonts/OTF
  '';
}
