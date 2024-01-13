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
      inherit (config.colours) primary alpha accent;
    in ''
      [colors.bright]
      black = '#${accent.black}'
      red = '#${accent.red}'
      green = '#${accent.green}'
      yellow = '#${accent.yellow}'
      blue = '#${accent.blue}'
      magenta = '#${accent.magenta}'
      cyan = '#${accent.cyan}'
      white = '#${accent.white}'
      [colors.normal]
      black = '#${alpha.black}'
      red = '#${alpha.red}'
      green = '#${alpha.green}'
      yellow = '#${alpha.yellow}'
      blue = '#${alpha.blue}'
      magenta = '#${alpha.magenta}'
      cyan = '#${alpha.cyan}'
      white = '#${alpha.white}'
      [colors.primary]
      background = '#${primary.bg}'
      bright_foreground = '#${primary.fg}'
      dim_foreground = '#${primary.fg}'
      foreground = '#${primary.fg}'
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
