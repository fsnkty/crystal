{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libxkbcommon
, stdenv
, wayland
}:

rustPlatform.buildRustPackage rec {
  pname = "rwpspread";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "0xk1f0";
    repo = "rwpspread";
    rev = "v${version}";
    hash = "sha256-slxsicASZ7JoUnnQf4R3xFB4zgtt4ZOZCU0NcbgBneM=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "smithay-client-toolkit-0.18.0" = "sha256-6y5abqVHPJmh8p8yeNgfTRox1u/2XHwRo3+T19I1Ksk=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libxkbcommon
  ] ++ lib.optionals stdenv.isLinux [
    wayland
  ];

  meta = with lib; {
    description = "Multi-Monitor Wallpaper Utility";
    homepage = "https://github.com/0xk1f0/rwpspread";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "rwpspread";
  };
}
