{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.local.desktop.sway = lib.mkEnableOption "";
  config = lib.mkIf config.local.desktop.sway {
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
          phinger-cursors
          inputs.mountain.packages.${pkgs.system}.gtk
          flat-remix-icon-theme
          vulkan-validation-layers # vulkan req, waiting on upstream to remove this hard dep.
          xdg-utils # defines what opens where.
          autotiling-rs # tile rules.
          swaylock
          swayidle
          wl-clipboard
          wofi
          waybar
        ];
        # nixos uses logind by default not seatd, java apps need the bottom flag.
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
      lcp = config.local.colours.primary;
      ccs = lib.concatStrings;
      ccms = lib.concatMapStringsSep;
      inherit (lib) replicate range getExe;
      inherit (pkgs) grim slurp jq;
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
      ${ccms "\n" (n: "workspace ${n} output ${d1}") (map toString (range 1 4))}
      ${ccms "\n" (n: "workspace ${n} output ${d2}") (map toString (range 5 8))}
      # visual
      output ${d1} background wallpaper1 fill
      output ${d2} background wallpaper2 fill
      default_border pixel 3
      gaps inner 5
      client.focused ${ccs (replicate 4 "#${lcp.main} ")}
      client.unfocused ${ccs (replicate 4 "#${lcp.bg} ")}
      client.focused_inactive ${ccs (replicate 4 "#${lcp.bg} ")}
      seat seat0 xcursor_theme phinger-cursors 24
      # keybinds
      bindsym ${m}+Return exec alacritty
      bindsym ${m}+Shift+q kill
      bindsym ${m}+d exec wofi --show drun -a -W 15% -H 35%
      bindsym ${m}+Shift+s exec ${getExe grim} -g "$(${getExe slurp} -d)" - | wl-copy -t image/png
      bindsym ${m}+Shift+d exec ${getExe grim} -g "$(swaymsg -t get_tree | ${getExe jq} -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | ${getExe slurp} -d)" - | wl-copy -t image/png
      bindsym ${m}+Shift+e exec swaynag -t warning -m 'confirm quit sway' -B 'confirm' 'swaymsg exit'
      bindsym ${m}+l exec swaylock -f -c 000000
      floating_modifier ${m} normal
      bindsym ${m}+Shift+a floating toggle
      bindsym ${m}+Shift+z fullscreen toggle
      ${ccms "\n" (n: "bindsym ${m}+${n} focus ${n}") directions}
      ${ccms "\n" (n: "bindsym ${m}+Shift+${n} move ${n}") directions}
      ${ccms "\n" (n: "bindsym ${m}+${n} workspace number ${n}") (map toString (range 1 8))}
      ${ccms "\n" (n: "bindsym ${m}+Shift+${n} move container to workspace number ${n}") (map toString (range 1 8))}
    '';
  };
}
