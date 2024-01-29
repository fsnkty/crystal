{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vue-torrent";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "VueTorrent";
    repo = "VueTorrent";
    rev = "v${finalAttrs.version}";
    hash = "sha256-05kJ8RfzYFrUWmP8H1gfky61CnxYuGc0lAkKHizW24A=";
  };
  dontUnpack = true;
  installPhase = ''
    cp $src $out/
  '';

  meta = {
    description = "The sleekest looking WEBUI for qBittorrent made with Vuejs";
    homepage = "https://github.com/VueTorrent/VueTorrent";
    changelog = "https://github.com/VueTorrent/VueTorrent/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [nu-nu-ko];
    mainProgram = "vue-torrent";
    platforms = lib.platforms.all;
  };
})
