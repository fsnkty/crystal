{
  config,
  lib,
  pkgs,
  ...
}: {
  options.program.alacritty = lib.mkEnableOption "";
  config = lib.mkIf config.program.alacritty {
    users.users.main.packages = [pkgs.alacritty];
    home.file.".config/alacritty/alacritty.toml".text = let
      lcp = config.colours.primary;
      lca = config.colours.alpha;
      lcac = config.colours.accent;
    in ''
      [colors.bright]
      black = '#${lcac.black}'
      red = '#${lcac.red}'
      green = '#${lcac.green}'
      yellow = '#${lcac.yellow}'
      blue = '#${lcac.blue}'
      magenta = '#${lcac.magenta}'
      cyan = '#${lcac.cyan}'
      white = '#${lcac.white}'
      [colors.normal]
      black = '#${lca.black}'
      red = '#${lca.red}'
      green = '#${lca.green}'
      yellow = '#${lca.yellow}'
      blue = '#${lca.blue}'
      magenta = '#${lca.magenta}'
      cyan = '#${lca.cyan}'
      white = '#${lca.white}'
      [colors.primary]
      background = '#${lcp.bg}'
      bright_foreground = '#${lcp.fg}'
      dim_foreground = '#${lcp.fg}'
      foreground = '#${lcp.fg}'
      [cursor]
      style = 'Underline'
      unfocused_hollow = false
      [window]
      dynamic_padding = false
      dynamic_title = true
      opacity = 1
      [window.padding]
      x = 8
      y = 8
    '';
  };
}
