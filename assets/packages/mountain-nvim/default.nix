{ pkgs }:
pkgs.vimUtils.buildVimPlugin {
  name = "mountain-nvim";
  src = ./nvim;
}
