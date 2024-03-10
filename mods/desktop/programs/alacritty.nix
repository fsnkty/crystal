{
  colours,
  config,
  nuke,
  pkgs,
  lib,
  ...
}:
{
  options.desktop.program.alacritty = nuke.mkEnable;
  config = lib.mkIf config.desktop.program.alacritty {
    users.users.main.packages = [ pkgs.alacritty ];
    home.file.".config/alacritty/alacritty.toml".source =
      (pkgs.formats.toml { }).generate "alacritty.toml"
        {
          colors =
            let
              inherit (colours) accent alpha;
              inherit (colours.primary) bg fg;
            in
            {
              bright = builtins.mapAttrs (_: prev: "#${prev}") (accent);
              normal = builtins.mapAttrs (_: prev: "#${prev}") (alpha);
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
            opacity = 1;
            padding = {
              x = 8;
              y = 8;
            };
          };
        };
  };
}
