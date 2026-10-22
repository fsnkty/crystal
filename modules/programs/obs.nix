{ config
, lib
, pkgs
, ...
}:
{
  options.crystal.programs.obs = lib.mkEnableOption "";
  config = lib.mkIf config.crystal.programs.obs {
    programs.obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
      ];
    };
  };
}
