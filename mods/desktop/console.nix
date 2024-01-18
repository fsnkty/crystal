{
  pkgs,
  config,
  lib,
  ...
}: {
  options.desktop.console = lib.mkEnableOption "";
  config = lib.mkIf config.desktop.console {
    console = {
      earlySetup = true;
      font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
      packages = with pkgs; [terminus_font];
      keyMap = "us";
      colors = let
        inherit (config.colours) alpha accent primary;
      in [
        "000000" # match boot.
        alpha.red
        alpha.green
        alpha.yellow
        alpha.blue
        alpha.magenta
        alpha.cyan
        alpha.white
        accent.red
        accent.green
        accent.yellow
        accent.blue
        accent.magenta
        accent.cyan
        accent.white
        primary.fg
      ];
    };
    # auto specify username.
    services.getty = {
      extraArgs = ["--skip-login"];
      loginOptions = "-- ${config.users.users.main.name}";
    };
  };
}
