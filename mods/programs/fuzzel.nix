{
  _colours,
  config,
  pkgs,
  _lib,
  lib,
  ...
}:
{
  options._programs.fuzzel = _lib.mkEnable;
  config = lib.mkIf config._programs.fuzzel {
    users.users.main.packages = [ pkgs.fuzzel ];
    environment.etc."xdg/fuzzel/fuzzel.ini".source = (pkgs.formats.ini { }).generate "fuzzel.ini" {
      colors =
        let
          inherit (_colours.primary) bg fg main;
        in
        {
          background = bg + "FF";
          text = fg + "FF";
          match = main + "FF";
          border = main + "FF";
        };
    };
  };
}
