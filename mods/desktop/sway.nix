{
  pkgs,
  lib,
  config,
  ...
}: {
  options.desktop.sway = lib.mkEnableOption "";
  config = lib.mkIf config.desktop.sway {
    programs = {
      zsh.loginShellInit = ''
        if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec sway
        fi
      '';
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          vulkan-validation-layers # upstream might remove this dep soon.
          autotiling-rs # tile rules.
          wl-clipboard
          swaylock
          swayidle
        ];
        extraSessionCommands = ''
          export LIBSEAT_BACKEND=logind
          export WLR_RENDERER=vulkan
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
    };
    home.file. ".config/sway/config".text = let
      d1 = "DP-1";
      d2 = "HDMI-A-1";
      m = "Mod4";
      directions = ["left" "down" "up" "right"];
      inherit (lib) replicate range getExe concatMapStringsSep concatStrings;
      inherit (pkgs) grim slurp;
      inherit (config.colours) primary;
    in ''
      xwayland enable
      exec {
        autotiling-rs
        waybar
        swayidle -w before-sleep 'swaylock -f -c 000000'
      }
      input "5426:132:Razer_Razer_DeathAdder_V2" accel_profile flat
      output ${d1} {
        mode 1920x1080@144Hz
        position 0,0
        adaptive_sync on
      }
      output ${d2} {
        mode 1920x1080@60Hz
        position 1920,0
      }
      ${concatMapStringsSep "\n" (n: "workspace ${n} output ${d1}") (map toString (range 1 4))}
      ${concatMapStringsSep "\n" (n: "workspace ${n} output ${d2}") (map toString (range 5 8))}
      # visual
      output ${d1} background wallpaper1 fill
      output ${d2} background wallpaper2 fill
      default_border pixel 3
      gaps inner 5
      client.focused ${concatStrings (replicate 4 "#${primary.main} ")}
      client.unfocused ${concatStrings (replicate 4 "#${primary.bg} ")}
      client.focused_inactive ${concatStrings (replicate 4 "#${primary.bg} ")}
      seat seat0 xcursor_theme phinger-cursors 24
      # keybinds
      bindsym ${m}+Return exec alacritty
      bindsym ${m}+Shift+q kill
      bindsym ${m}+d exec wofi --show drun -a -W 15% -H 35%
      bindsym ${m}+Shift+s exec ${getExe grim} -g "$(${getExe slurp} -d)" - | wl-copy -t image/png
      bindsym ${m}+Shift+e exec swaynag -t warning -m 'confirm quit sway' -B 'confirm' 'swaymsg exit'
      bindsym ${m}+l exec swaylock -f -c 000000
      floating_modifier ${m} normal
      bindsym ${m}+Shift+a floating toggle
      bindsym ${m}+Shift+z fullscreen toggle
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+${n} focus ${n}") directions}
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+Shift+${n} move ${n}") directions}
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+${n} workspace number ${n}") (map toString (range 1 8))}
      ${concatMapStringsSep "\n" (n: "bindsym ${m}+Shift+${n} move container to workspace number ${n}") (map toString (range 1 8))}
    '';
  };
}
