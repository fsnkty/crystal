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
  version = "test";

  src = fetchFromGitHub {
    owner = "nu-nu-ko";
    repo = "rwpspread";
    rev = version;
    hash = "sha256-CRlp5g6kcUk+w3qcwmICq/BTftB2bgxjUF7gBBFAEaY=";
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
    homepage = "https://github.com/nu-nu-ko/rwpspread";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nu-nu-ko ];
    mainProgram = "rwpspread";
  };
}
