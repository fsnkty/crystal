{ config, pkgs, lib, ... }:

let
  krisp-patcher =
    pkgs.writers.writePython3Bin "krisp-patcher"
      {
        libraries = with pkgs.python3Packages; [
          capstone
          pyelftools
        ];
        flakeIgnore = [
          "E265" # from nix-shell shebang
          "E501" # line too long (82 > 79 characters)
          "F403" # 'from module import *' used; unable to detect undefined names
          "F405" # name may be undefined, or defined from star imports: module
        ];
      }
      (
        builtins.readFile (
          pkgs.fetchurl {
            url = "https://pastebin.com/raw/8tQDsMVd";
            sha256 = "sha256-IdXv0MfRG1/1pAAwHLS2+1NESFEz2uXrbSdvU9OvdJ8=";
          }
        )
      );

  discord = (pkgs.discord.override {
    withTTS = false;
    withOpenASAR = true;
  }).overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      ${pkgs.findutils}/bin/find "$out/opt/Discord/modules" \
        -name 'discord_krisp.node' -exec ${lib.getExe krisp-patcher} {} \;
    '';
    stageModules = pkgs.writeShellScript "discord-stage-mine" ''
      store_modules="$1"
      modules_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/discord/${old.version}/modules"

      mkdir -p "$modules_dir"
      for m in "$store_modules"/*; do
        dest="$modules_dir/$(basename "$m")"

        if [ -L "$dest" ]; then
          rm "$dest"
        fi

        ${lib.getExe' pkgs.rsync "rsync"} -a --checksum --delete "$m/" "$dest"
      done

      chmod -R u+w "$modules_dir"

      echo '${
        builtins.toJSON (lib.mapAttrs (_: mod: { installedVersion = mod; }) old.passthru.moduleVersions)
      }' \
        > "$modules_dir/installed.json"
    '';
  });
in
{
  options.crystal.programs.discord = lib.mkEnableOption "";

  config = lib.mkIf config.crystal.programs.discord {
    users.users.main.packages = [ discord ];
    hjem.users.main.xdg.config.files."autostart/discord.desktop" = {
      text = ''
        [Desktop Entry]
        Name=Discord Auto Start
        Exec=discord --start-minimized
        Icon=discord
        Type=Application
        X-GNOME-Autostart-enabled=true
      '';
      # discord will try put its own here if the settings changed
      clobber = true;
    };
  };
}
