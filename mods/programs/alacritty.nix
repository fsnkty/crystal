{
  _colours,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._programs.alacritty = _lib.mkEnable;
  config = lib.mkIf config._programs.alacritty {
    users.users.main.packages = [ pkgs.alacritty ];
    _homeFile.".config/alacritty/alacritty.toml".source =
      (pkgs.formats.toml { }).generate "alacritty.toml"
        {
          colors =
            let
              inherit (_colours) accent alpha primary;
              inherit (primary) fg bg;
              inherit (builtins) mapAttrs;
            in
            {
              bright = mapAttrs (_: x: "#${x}") accent;
              normal = mapAttrs (_: x: "#${x}") alpha;
              primary = {
                background = "#${bg}";
                bright_foreground = "#${fg}";
                dim_foreground = "#${fg}";
              };
            };
          cursor = {
            style = "Underline";
            unfocused_hollow = false;
          };
          window = {
            dynamic_padding = false;
            dynamic_title = true;
            padding = {
              x = 8;
              y = 8;
            };
          };
        };
  };
}
