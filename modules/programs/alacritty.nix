{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.crystal.programs.alacritty = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.programs.alacritty {
    environment = {
      systemPackages = [ pkgs.alacritty ];
      etc."alacritty/alacritty.toml".text = ''
        [window]
        padding = {
          y = 4,
          x = 4,
        }
        [colors.primary]
        foreground = "#bbbbbb"
        background = "#191919"

        [colors.cursor]
        text = "#191919"
        cursor = "#c9c9c9"

        [colors.selection]
        text = "#bbbbbb"
        background = "#404040"

        [colors.normal]
        black = "#191919"
        red = "#de6e7c"
        green = "#819b69"
        yellow = "#b77e64"
        blue = "#6099c0"
        magenta = "#b279a7"
        cyan = "#66a5ad"
        white = "#bbbbbb"

        [colors.bright]
        black = "#3d3839"
        red = "#e8838f"
        green = "#8bae68"
        yellow = "#d68c67"
        blue = "#61abda"
        magenta = "#cf86c1"
        cyan = "#65b8c1"
        white = "#8e8e8e"
      '';
    };
  };
}
